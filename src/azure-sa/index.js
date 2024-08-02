const express = require('express');
const multer = require('multer');
const fs = require('fs');
const path = require('path');
require('dotenv').config();

const { BlobServiceClient, StorageSharedKeyCredential } = require('@azure/storage-blob');
const { MongoClient, ObjectId } = require('mongodb');

const app = express();
const PORT = process.env.PORT || 3000;

const upload = multer({ dest: 'uploads/' });

const sharedKeyCredential = new StorageSharedKeyCredential(
    process.env.AZURE_STORAGE_ACCOUNT_NAME,
    process.env.AZURE_STORAGE_ACCOUNT_KEY
);

const blobServiceClient = new BlobServiceClient(
    `https://${process.env.AZURE_STORAGE_ACCOUNT_NAME}.blob.core.windows.net`,
    sharedKeyCredential
);

const containerClient = blobServiceClient.getContainerClient(process.env.AZURE_CONTAINER_NAME);

const client = new MongoClient(process.env.MONGODB_URI);
let db, filesCollection;

async function connectDB() {
    try {
        await client.connect();
        db = client.db(process.env.MONGODB_DB_NAME);
        filesCollection = db.collection('files');
        console.log('Connected to MongoDB');
    } catch (err) {
        console.error('Error connecting to MongoDB:', err);
    }
}

connectDB();

app.use(express.static(path.join(__dirname, 'public')));
app.use(express.json());

app.post('/upload', upload.single('file'), async (req, res) => {
    const fileName = req.body.note;
    if (!fileName) {
        return res.status(400).send('File name is required.');
    }

    if (req.file) {
        try {
            const blobName = req.file.filename;
            const blockBlobClient = containerClient.getBlockBlobClient(blobName);

            await blockBlobClient.uploadFile(req.file.path);
            fs.unlinkSync(req.file.path); // remove the file locally after upload

            const fileRecord = { name: fileName, key: blobName };
            await filesCollection.insertOne(fileRecord);

            res.status(200).send('File uploaded successfully.');
        } catch (err) {
            console.error('Error uploading file:', err);
            res.status(500).send('Failed to upload file.');
        }
    } else {
        res.status(400).send('No file uploaded.');
    }
});

app.get('/files', async (req, res) => {
    try {
        const files = await filesCollection.find().toArray();
        res.json(files);
    } catch (err) {
        console.error('Error fetching files:', err);
        res.status(500).send('Failed to fetch files.');
    }
});

app.delete('/files/:key', async (req, res) => {
    const fileKey = req.params.key;

    try {
        const blockBlobClient = containerClient.getBlockBlobClient(fileKey);
        await blockBlobClient.delete();

        await filesCollection.deleteOne({ key: fileKey });

        res.status(200).send('File deleted successfully.');
    } catch (err) {
        console.error('Error deleting file:', err);
        res.status(500).send('Failed to delete file.');
    }
});

app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});
