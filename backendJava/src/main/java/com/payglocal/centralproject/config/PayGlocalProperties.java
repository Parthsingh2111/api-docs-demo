package com.payglocal.centralproject.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Configuration;

@Configuration
@ConfigurationProperties(prefix = "payglocal")
public class PayGlocalProperties {
	private String merchantId;
	private String publicKeyId;
	private String privateKeyId;
	private String publicKeyPath;
	private String privateKeyPath;
	private String environment; // UAT or PROD
	private String logLevel;

	public String getMerchantId() { return merchantId; }
	public void setMerchantId(String merchantId) { this.merchantId = merchantId; }
	public String getPublicKeyId() { return publicKeyId; }
	public void setPublicKeyId(String publicKeyId) { this.publicKeyId = publicKeyId; }
	public String getPrivateKeyId() { return privateKeyId; }
	public void setPrivateKeyId(String privateKeyId) { this.privateKeyId = privateKeyId; }
	public String getPublicKeyPath() { return publicKeyPath; }
	public void setPublicKeyPath(String publicKeyPath) { this.publicKeyPath = publicKeyPath; }
	public String getPrivateKeyPath() { return privateKeyPath; }
	public void setPrivateKeyPath(String privateKeyPath) { this.privateKeyPath = privateKeyPath; }
	public String getEnvironment() { return environment; }
	public void setEnvironment(String environment) { this.environment = environment; }
	public String getLogLevel() { return logLevel; }
	public void setLogLevel(String logLevel) { this.logLevel = logLevel; }
} 



// PAYGLOCAL_API_KEY=dGVzdG5ld2djYzI2OmtJZC1Ka3NGczBGdmJyajNkSjJQ
// PAYGLOCAL_MERCHANT_ID=   testnewgcc26
// PAYGLOCAL_PUBLIC_KEY_ID= kId-yLtRky48X2HqW30k
// PAYGLOCAL_PRIVATE_KEY_ID=kId-vU6e8l6bWtXK8oOK
// PAYGLOCAL_PUBLIC_KEY=/Users/parthsingh/proj/payglocalCentraProject/centralproject/backend/keys/payglocal_public_key
// PAYGLOCAL_PRIVATE_KEY=/Users/parthsingh/proj/payglocalCentraProject/centralproject/backend/keys/payglocal_private_key
// PAYGLOCAL_Env_VAR=UAT
// PAYGLOCAL_LOG_LEVEL=debug



 