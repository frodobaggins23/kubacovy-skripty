# Email Attachment Extractor

This script extracts attachments from an mbox file and saves them to a specified directory.

## Description

The script processes an mbox file, iterates through its messages, and extracts attachments from multipart messages. It saves the attachments to folder `attachments`, ensuring that the filenames are sanitized and valid.

## Usage

```bash
./get-email-attachments.py ./your-mbox-file.mbox
```
