# Documentation

This directory contains the complete documentation for `json_serializer` using Docsify.

## Viewing the Documentation

### Option 1: Using Docsify CLI (Recommended)

1. Install Docsify CLI globally:
```bash
npm i docsify-cli -g
```

2. Serve the documentation:
```bash
docsify serve docs
```

3. Open your browser to `http://localhost:3000`

### Option 2: Using Python HTTP Server

1. Navigate to the docs directory:
```bash
cd docs
```

2. Start a simple HTTP server:
```bash
# Python 3
python3 -m http.server 8000

# Python 2
python -m SimpleHTTPServer 8000
```

3. Open your browser to `http://localhost:8000`

### Option 3: Using Node.js http-server

1. Install http-server:
```bash
npm install -g http-server
```

2. Serve the documentation:
```bash
http-server docs -p 8000
```

3. Open your browser to `http://localhost:8000`

## Documentation Structure

- **README.md** - Overview and quick start
- **getting-started.md** - Installation and basic usage
- **serialization.md** - Converting Dart objects to JSON
- **deserialization.md** - Converting JSON to Dart objects
- **types.md** - UserType, EnumType, and GenericType
- **naming-conventions.md** - Property name conversion
- **converters.md** - Custom type converters
- **options.md** - Configuration options
- **advanced.md** - Advanced usage and best practices
- **api-reference.md** - Complete API reference

## Publishing

To publish the documentation to GitHub Pages:

1. Push the `docs` directory to your repository
2. Enable GitHub Pages in repository settings
3. Select the `docs` folder as the source

The documentation will be available at:
`https://yourusername.github.io/json_serializer/`
