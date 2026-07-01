FROM python:3.11-slim

WORKDIR /app

# Install system dependencies needed for Chrome/Playwright, plus Node.js for the SSE proxy
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libnss3 \
    libatk-bridge2.0-0 \
    libxss1 \
    libasound2 \
    libgbm1 \
    libgtk-3-0 \
    libxshmfence-dev \
    libxrandr2 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxi6 \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install the official MCP SSE proxy server globally
RUN npm install -g @modelcontextprotocol/server-express

# Copy project files
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Install playwright headless browsers for scraping
RUN python -m playwright install chromium

# Hugging Face Spaces strictly requires port 7860
EXPOSE 7860

# Launches the express proxy on port 7860, running the python script internally
CMD ["mcp-server-express", "python", "-m", "crawler_agent.mcp_server", "--port", "7860"]
