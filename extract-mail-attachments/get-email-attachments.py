import os
import mailbox
import re
from email import header, utils
import sys

script_directory = os.path.dirname(os.path.abspath(__file__))
save_path = os.path.join(script_directory, 'attachments')
excluded_filetypes = ['.ics','.exe', '.bat', '.com', '.pif', '.scr', '.vbs', '.js']


def sanitize_filename(filename):
    return re.sub(r'[\\/:"*?<>|]+', "_", filename)

def decode_rfc2047(encoded_string):
    decoded_fragments = header.decode_header(encoded_string)
    decoded_string = ''
    for fragment, encoding in decoded_fragments:
        if isinstance(fragment, bytes):
            encoding = encoding or 'utf-8'
            fragment = fragment.decode(encoding, errors='ignore')
        decoded_string += fragment
    return decoded_string

def get_destination_folder(message):
    date_tuple = utils.parsedate_tz(message['Date'])
    if date_tuple:
        year = date_tuple[0]
        month = date_tuple[1]
        month_path = os.path.join(save_path, f"{year}", f"{month:02d}")
        os.makedirs(month_path, exist_ok=True)
        return month_path
    default_path = os.path.join(save_path, 'unknown')
    os.makedirs(default_path, exist_ok=True)
    return default_path

def is_excluded_filetype(filename):
    if not filename:
        return False
    return any(filename.lower().endswith(ext) for ext in excluded_filetypes)

def main(mbox_filename):

    mbox_file_path = os.path.join(script_directory, mbox_filename)

    if not os.path.exists(mbox_file_path):
        print(f"File {mbox_file_path} does not exist.")
        sys.exit(1)

    os.makedirs(save_path, exist_ok=True)

    mbox = mailbox.mbox(mbox_file_path)

    for message in mbox:
        if message.is_multipart():
            for part in message.walk():
                if part.get_content_disposition() == 'attachment':
                    raw_filename = part.get_filename()

                    if raw_filename:
                        decoded_filename = decode_rfc2047(raw_filename)
                        filename = sanitize_filename(decoded_filename)

                        isNOK = is_excluded_filetype(filename)

                        if isNOK:
                            break

                        destination_folder = get_destination_folder(message)

                        print(f"Extracting attachment: {filename} to {destination_folder}")

                        filepath = os.path.join(destination_folder, filename)
                        with open(filepath, 'wb') as f:
                            f.write(part.get_payload(decode=True))

    print("Attachments extracted successfully.")

# Run the script with the mbox file as an argument
if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python get-email-attachments.py <mbox_filename>")
        sys.exit(1)
    mbox_filename = sys.argv[1]
    main(mbox_filename)