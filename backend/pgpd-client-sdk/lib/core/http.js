/**
 * HTTP client using native fetch with retry logic
 * Used Fetch  for better performance and fewer dependencies
 */

const { logger } = require('../utils/logger');



/**
 * Check if error is retryable
 * @param {Error} error - Error to check
 * @returns {boolean} Whether error is retryable
 */

/**
 * Make HTTP request with retry logic (RETRY LOGIC DISABLED)
 * @param {string} url - Request URL
 * @param {Object} options - Fetch options
 * @param {number} maxRetries - Maximum retry attempts
 * @returns {Promise<Object>} Response data
 */
async function makeRequest(url, options, maxRetries = 3) {

      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), 10000); // 10 second timeout
      
      const fetchOptions = {
        ...options,
        signal: controller.signal,
        headers: {
          'User-Agent': 'PayGlocal-SDK/1.0.3',
          ...options.headers
        }
      };
      
      const response = await fetch(url, fetchOptions);
      clearTimeout(timeoutId);
      
      // Check if response is ok (status 200-299)
      if (!response.ok) {
        const errorData = await response.text().catch(() => 'Unknown error');
        const error = new Error(`HTTP ${response.status}: ${errorData}`);
        error.status = response.status;
        error.response = response;
        throw error;
      }
      
      // Parse response
      const contentType = response.headers.get('content-type');
      let data;
      
      // Try to parse as JSON first, fallback to text
      try {
        data = await response.json();
      } catch (jsonError) {
        // If JSON parsing fails, get as text
        data = await response.text();
        
        // Try to parse text as JSON if it looks like JSON
        if (typeof data === 'string' && (data.trim().startsWith('{') || data.trim().startsWith('['))) {
          try {
            data = JSON.parse(data);
          } catch (parseError) {
            // Keep as string if JSON parsing fails
            logger.debug('Response is not valid JSON, keeping as string');
          }
        }
      }
      
      return data;
}

/**
 * Make POST request
 * @param {string} url - Request URL
 * @param {Object|string} data - Request payload
 * @param {Object} headers - Request headers
 * @returns {Promise<Object>} Response data
 */
async function post(url, data, headers = {}) {
  try {
    logger.logRequest('POST', url, headers, data);
    
    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...headers
      }
    };
    
    // Handle different data types
    if (typeof data === 'string') {
      options.body = data;
      options.headers['Content-Type'] = 'text/plain';
    } else if (data !== null && data !== undefined) {
      options.body = JSON.stringify(data);
    }
    
    const response = await makeRequest(url, options);
    logger.logResponse('POST', url, 200, response);
    
    return response || {};
  } catch (error) {
    logger.error(`POST request failed: ${url}`, error);
    
    if (error.response) {
      logger.logResponse('POST', url, error.status, error.message);
      throw new Error(`API error: ${error.message}`);
    } else if (error.name === 'AbortError') {
      throw new Error('Request timeout');
    } else {
      throw new Error(`Request failed: ${error.message}`);
    }
  }
}

/**
 * Make GET request
 * @param {string} url - Request URL
 * @param {Object} headers - Request headers
 * @returns {Promise<Object>} Response data
 */
async function get(url, headers = {}) {
  try {
    logger.logRequest('GET', url, headers);
    
    const options = {
      method: 'GET',
      headers: {
        ...headers
      }
    };
    
    const response = await makeRequest(url, options);
    logger.logResponse('GET', url, 200, response);
    
    return response || {};
  } catch (error) {
    logger.error(`GET request failed: ${url}`, error);
    
    if (error.response) {
      logger.logResponse('GET', url, error.status, error.message);
      throw new Error(`API error: ${error.message}`);
    } else if (error.name === 'AbortError') {
      throw new Error('Request timeout');
    } else {
      throw new Error(`Request failed: ${error.message}`);
    }
  }
}

module.exports = { post, get };


