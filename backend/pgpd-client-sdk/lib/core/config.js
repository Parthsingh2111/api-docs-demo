/**
 * Configuration class for PayGlocalClient.
 * @class
 * @param {Object} config - Configuration object
 */
class Config {
  constructor(config = {}) {
    this.apiKey = config.apiKey || '';
    this.merchantId = config.merchantId || '';
    this.publicKeyId = config.publicKeyId || '';
    this.privateKeyId = config.privateKeyId || '';
    this.payglocalPublicKey = config.payglocalPublicKey || '';
    this.merchantPrivateKey = config.merchantPrivateKey || '';
    this.baseUrl = config.baseUrl || 'https://api.uat.payglocal.in';
    this.logLevel = config.logLevel || 'info';

    // Validate required fields
    if (!this.merchantId) throw new Error('Missing required configuration: merchantId');
    
    // Require either API key or all token fields
    if (!this.apiKey && (!this.publicKeyId || !this.privateKeyId || !this.payglocalPublicKey || !this.merchantPrivateKey)) {
      throw new Error('Missing required configuration: either apiKey or all token fields (publicKeyId, privateKeyId, payglocalPublicKey, merchantPrivateKey)');
    }
  }
}

module.exports = Config;