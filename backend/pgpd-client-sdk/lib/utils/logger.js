// lib/utils/logger.js

class Logger {
  constructor(level = 'info') {
    this.level = level;
  }

  info(message) {
    if (this.level === 'info' || this.level === 'debug') {
      console.log(`[INFO] ${message}`);
    }
  }

  debug(message) {
    if (this.level === 'debug') {
      console.debug(`[DEBUG] ${message}`);
    }
  }

  error(message) {
    console.error(`[ERROR] ${message}`);
  }

  logRequest(method, url, headers = {}, body) {
    const hdr = JSON.stringify(headers);
    const b = body === undefined ? '' : ` | body=${typeof body === 'string' ? body : JSON.stringify(body)}`;
    this.debug(`[REQUEST] ${method} ${url} | headers=${hdr}${b}`);
  }
  
  logResponse(method, url, status, data) {
    const d = typeof data === 'string' ? data : JSON.stringify(data);
    this.debug(`[RESPONSE] ${method} ${url} | status=${status} | body=${d}`);
  }
}

const logger = new Logger(process.env.PAYGLOCAL_LOG_LEVEL || 'info');

module.exports = { logger };







