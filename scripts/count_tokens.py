# filename: count_tokens.py
import sys
import tiktoken

def count_tokens(text, model="gpt-3.5-turbo"):
    encoding = tiktoken.encoding_for_model(model)
    tokens = encoding.encode(text)
    return len(tokens)

if __name__ == "__main__":
    content = sys.stdin.read()
    print(count_tokens(content))

