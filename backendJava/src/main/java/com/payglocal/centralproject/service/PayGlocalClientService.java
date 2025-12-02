package com.payglocal.centralproject.service;

import com.payglocal.centralproject.config.PayGlocalProperties;
import org.springframework.stereotype.Service;

import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.CompletableFuture;

// SDK imports
import com.payglocal.sdk.PayGlocalClient;
import com.payglocal.sdk.core.Config;

@Service
public class PayGlocalClientService {
	private final PayGlocalProperties props;
	private final PayGlocalClient client;

	public PayGlocalClientService(PayGlocalProperties props) {
		this.props = props;
		this.client = new PayGlocalClient(buildConfig(props));
	}

	public Map<String, Object> initiateJwtPayment(Map<String, Object> payload) {
		return await(client.initiateJwtPayment(payload));
	}

	public Map<String, Object> initiateSiPayment(Map<String, Object> payload) {
		return await(client.initiateSiPayment(payload));
	}

	public Map<String, Object> initiateAuthPayment(Map<String, Object> payload) {
		return await(client.initiateAuthPayment(payload));
	}

	public Map<String, Object> initiateRefund(Map<String, Object> payload) {
		return await(client.initiateRefund(payload));
	}

	public Map<String, Object> initiateCapture(String gid, Map<String, Object> payload) {
		Map<String, Object> params = new HashMap<>(payload);
		params.put("gid", gid);
		return await(client.initiateCapture(params));
	}

	public Map<String, Object> initiateAuthReversal(String gid) {
		Map<String, Object> params = new HashMap<>();
		params.put("gid", gid);
		return await(client.initiateAuthReversal(params));
	}

	public Map<String, Object> checkStatus(String gid) {
		Map<String, Object> params = new HashMap<>();
		params.put("gid", gid);
		return await(client.initiateCheckStatus(params));
	}

	private static Map<String, Object> await(CompletableFuture<Map<String, Object>> future) {
		try {
			return future.join();
		} catch (Exception e) {
			throw new RuntimeException(e.getMessage(), e);
		}
	}

	private static String readFile(String path) {
		try {
			return Files.readString(Path.of(path));
		} catch (Exception e) {
			throw new RuntimeException("Failed to read key file: " + path, e);
		}
	}

	private static Config buildConfig(PayGlocalProperties p) {
		Config.Builder b = new Config.Builder()
			.merchantId(p.getMerchantId())
			.payglocalEnv(p.getEnvironment())
			.logLevel(p.getLogLevel());

		// Prefer JWT if public/private key ids are set; otherwise rely on API key if provided
		boolean jwtConfigured = p.getPublicKeyId() != null && p.getPrivateKeyId() != null;
		if (jwtConfigured) {
			b.publicKeyId(p.getPublicKeyId())
			 .privateKeyId(p.getPrivateKeyId())
			 .payglocalPublicKey(readFile(p.getPublicKeyPath()))
			 .merchantPrivateKey(readFile(p.getPrivateKeyPath()));
		}
		return b.build();
	}
} 