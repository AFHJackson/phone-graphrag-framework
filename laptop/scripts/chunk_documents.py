#!/usr/bin/env python3
"""
Chunk documents for GraphRAG phone processing.

This script takes PDF or text documents and splits them into chunks
suitable for entity extraction on the phone.

Usage:
    python chunk_documents.py --input data/docs/ --output chunks.json
    python chunk_documents.py --input file.pdf --output chunks.json --chunk-size 2500
"""

import json
import argparse
from pathlib import Path
from typing import List, Dict, Any
import hashlib

try:
    from langchain_text_splitters import RecursiveCharacterTextSplitter
    from pypdf import PdfReader
except ImportError as e:
    print(f"Missing dependency: {e}")
    print("Run: pip install -r requirements.txt")
    exit(1)


def extract_text_from_pdf(pdf_path: Path) -> str:
    """Extract text from a PDF file."""
    reader = PdfReader(str(pdf_path))
    text = ""
    for page_num, page in enumerate(reader.pages, 1):
        page_text = page.extract_text() or ""
        text += f"\n[Page {page_num}]\n{page_text}"
    return text


def extract_text_from_file(file_path: Path) -> str:
    """Extract text from various file types."""
    suffix = file_path.suffix.lower()
    
    if suffix == '.pdf':
        return extract_text_from_pdf(file_path)
    elif suffix in ['.txt', '.md', '.csv']:
        return file_path.read_text(encoding='utf-8', errors='ignore')
    else:
        print(f"Warning: Unsupported file type {suffix}, treating as text")
        return file_path.read_text(encoding='utf-8', errors='ignore')


def chunk_text(
    text: str,
    chunk_size: int = 2500,
    overlap: int = 200
) -> List[str]:
    """Split text into chunks using recursive character splitter."""
    splitter = RecursiveCharacterTextSplitter(
        chunk_size=chunk_size,
        chunk_overlap=overlap,
        length_function=len,
        separators=["\n\n", "\n", ". ", " ", ""]
    )
    return splitter.split_text(text)


def create_chunk_id(content: str, index: int) -> str:
    """Create a unique chunk ID."""
    # Use hash of content prefix + index for uniqueness
    content_hash = hashlib.md5(content[:100].encode()).hexdigest()[:6]
    return f"chunk_{index:03d}_{content_hash}"


def process_files(
    input_path: Path,
    chunk_size: int,
    overlap: int
) -> List[Dict[str, Any]]:
    """Process files and create chunks."""
    chunks = []
    chunk_index = 0
    
    # Handle single file or directory
    if input_path.is_file():
        files = [input_path]
    else:
        files = list(input_path.glob('**/*'))
        files = [f for f in files if f.is_file() and f.suffix.lower() in ['.pdf', '.txt', '.md']]
    
    for file_path in files:
        print(f"Processing: {file_path.name}")
        
        try:
            text = extract_text_from_file(file_path)
            file_chunks = chunk_text(text, chunk_size, overlap)
            
            for chunk_content in file_chunks:
                chunk = {
                    "id": f"chunk_{chunk_index:03d}",
                    "content": chunk_content,
                    "metadata": {
                        "source": file_path.name,
                        "source_path": str(file_path),
                        "chunk_index": chunk_index,
                        "char_count": len(chunk_content)
                    }
                }
                chunks.append(chunk)
                chunk_index += 1
            
            print(f"  → Created {len(file_chunks)} chunks")
            
        except Exception as e:
            print(f"  ✗ Error processing {file_path.name}: {e}")
    
    return chunks


def main():
    parser = argparse.ArgumentParser(description='Chunk documents for GraphRAG processing')
    parser.add_argument('--input', '-i', required=True, help='Input file or directory')
    parser.add_argument('--output', '-o', default='chunks.json', help='Output JSON file')
    parser.add_argument('--chunk-size', type=int, default=2500, help='Target chunk size in characters')
    parser.add_argument('--overlap', type=int, default=200, help='Overlap between chunks')
    
    args = parser.parse_args()
    
    input_path = Path(args.input)
    if not input_path.exists():
        print(f"Error: Input path does not exist: {input_path}")
        exit(1)
    
    print(f"Chunking documents from: {input_path}")
    print(f"Chunk size: {args.chunk_size}, Overlap: {args.overlap}")
    print()
    
    chunks = process_files(input_path, args.chunk_size, args.overlap)
    
    if not chunks:
        print("No chunks created. Check input files.")
        exit(1)
    
    # Create output structure
    output = {
        "chunks": chunks,
        "metadata": {
            "total_chunks": len(chunks),
            "chunk_size": args.chunk_size,
            "overlap": args.overlap,
            "source": str(input_path)
        }
    }
    
    # Write output
    output_path = Path(args.output)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output, f, indent=2, ensure_ascii=False)
    
    print()
    print(f"✓ Created {len(chunks)} chunks")
    print(f"✓ Output written to: {output_path}")
    
    # Show statistics
    sizes = [len(c['content']) for c in chunks]
    print(f"\nStatistics:")
    print(f"  Min size: {min(sizes)} chars")
    print(f"  Max size: {max(sizes)} chars")
    print(f"  Avg size: {sum(sizes) // len(sizes)} chars")


if __name__ == '__main__':
    main()
