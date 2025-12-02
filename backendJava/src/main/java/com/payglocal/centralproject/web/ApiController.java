package com.payglocal.centralproject.web;

import com.payglocal.centralproject.service.PayGlocalClientService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api")
public class ApiController {

	private final PayGlocalClientService clientService;

	public ApiController(PayGlocalClientService clientService) {
		this.clientService = clientService;
	}

	@PostMapping("/pay/jwt")
	public ResponseEntity<?> payJwt(@RequestBody Map<String, Object> body) {
		String merchantTxnId = (String) body.get("merchantTxnId");
		Object paymentData = body.get("paymentData");
		String merchantCallbackURL = (String) body.get("merchantCallbackURL");

		if (!StringUtils.hasText(merchantTxnId) || paymentData == null || !StringUtils.hasText(merchantCallbackURL)) {
			return validationError("merchantTxnId", "paymentData", "merchantCallbackURL");
		}
		Map<String, Object> sdk = asMap(clientService.initiateJwtPayment(body));
		return ResponseEntity.ok(formatPaymentResponse("Payment initiated successfully", sdk));
	}

	@PostMapping("/pay/si")
	public ResponseEntity<?> paySi(@RequestBody Map<String, Object> body) {
		String merchantTxnId = (String) body.get("merchantTxnId");
		Object paymentData = body.get("paymentData");
		Object standingInstruction = body.get("standingInstruction");
		String merchantCallbackURL = (String) body.get("merchantCallbackURL");

		if (!StringUtils.hasText(merchantTxnId) || paymentData == null || standingInstruction == null || !StringUtils.hasText(merchantCallbackURL)) {
			return validationError("merchantTxnId", "paymentData", "standingInstruction", "merchantCallbackURL");
		}
		Map<String, Object> sdk = asMap(clientService.initiateSiPayment(body));
		Map<String, Object> resp = formatPaymentResponse("SI Payment initiated successfully", sdk);
		resp.put("mandateId", firstNonNull(
			get(sdk, "mandateId"),
			getNested(sdk, "data", "mandateId"),
			getNested(sdk, "standingInstruction", "mandateId")
		));
		return ResponseEntity.ok(resp);
	}

	@PostMapping("/pay/auth")
	public ResponseEntity<?> payAuth(@RequestBody Map<String, Object> body) {
		String merchantTxnId = (String) body.get("merchantTxnId");
		Object paymentData = body.get("paymentData");
		String merchantCallbackURL = (String) body.get("merchantCallbackURL");

		if (!StringUtils.hasText(merchantTxnId) || paymentData == null || !StringUtils.hasText(merchantCallbackURL)) {
			return validationError("merchantTxnId", "paymentData", "merchantCallbackURL");
		}
		Map<String, Object> sdk = asMap(clientService.initiateAuthPayment(body));
		return ResponseEntity.ok(formatPaymentResponse("Auth Payment initiated successfully", sdk));
	}

	@PostMapping("/refund")
	public ResponseEntity<?> refund(@RequestBody Map<String, Object> body) {
		String gid = (String) body.get("gid");
		String refundType = (String) body.get("refundType");
		Map<String, Object> paymentData = (Map<String, Object>) body.get("paymentData");

		if (!StringUtils.hasText(gid)) {
			return validationError("gid");
		}
		if ("P".equalsIgnoreCase(refundType)) {
			if (paymentData == null || paymentData.get("totalAmount") == null) {
				return validationError("paymentData.totalAmount");
			}
		}
		Map<String, Object> sdk = asMap(clientService.initiateRefund(body));
		Map<String, Object> resp = baseSuccess("Refund completed");
		resp.put("gid", firstNonNull(
			get(sdk, "gid"), getNested(sdk, "data", "gid"), get(sdk, "transactionId"), getNested(sdk, "data", "transactionId")
		));
		resp.put("refundId", firstNonNull(
			get(sdk, "refundId"), getNested(sdk, "data", "refundId"), get(sdk, "id"), getNested(sdk, "data", "id")
		));
		resp.put("transactionStatus", firstNonNull(
			get(sdk, "status"), getNested(sdk, "data", "status"), get(sdk, "result"), getNested(sdk, "data", "result")
		));
		resp.put("raw_response", sdk);
		return ResponseEntity.ok(resp);
	}

	@PostMapping("/cap")
	public ResponseEntity<?> capture(@RequestParam("gid") String gid, @RequestBody Map<String, Object> body) {
		String captureType = (String) body.get("captureType");
		Map<String, Object> paymentData = (Map<String, Object>) body.get("paymentData");

		if (!StringUtils.hasText(gid)) {
			return validationError("gid");
		}
		if ("P".equalsIgnoreCase(captureType)) {
			if (paymentData == null || paymentData.get("totalAmount") == null) {
				return validationError("paymentData.totalAmount");
			}
		}
		Map<String, Object> sdk = asMap(clientService.initiateCapture(gid, body));
		Map<String, Object> resp = baseSuccess("Capture completed");
		resp.put("gid", firstNonNull(
			get(sdk, "gid"), getNested(sdk, "data", "gid"), get(sdk, "transactionId"), getNested(sdk, "data", "transactionId")
		));
		resp.put("captureId", firstNonNull(
			get(sdk, "captureId"), getNested(sdk, "data", "captureId"), get(sdk, "id"), getNested(sdk, "data", "id")
		));
		resp.put("transactionStatus", firstNonNull(
			get(sdk, "status"), getNested(sdk, "data", "status"), get(sdk, "result"), getNested(sdk, "data", "result")
		));
		resp.put("raw_response", sdk);
		return ResponseEntity.ok(resp);
	}

	@PostMapping("/authreversal")
	public ResponseEntity<?> authReversal(@RequestParam("gid") String gid) {
		if (!StringUtils.hasText(gid)) {
			return validationError("gid");
		}
		Map<String, Object> sdk = asMap(clientService.initiateAuthReversal(gid));
		Map<String, Object> resp = baseSuccess("Auth reversal completed");
		resp.put("gid", firstNonNull(
			get(sdk, "gid"), getNested(sdk, "data", "gid"), get(sdk, "transactionId"), getNested(sdk, "data", "transactionId")
		));
		resp.put("reversalId", firstNonNull(
			get(sdk, "reversalId"), getNested(sdk, "data", "reversalId"), get(sdk, "id"), getNested(sdk, "data", "id")
		));
		resp.put("transactionStatus", firstNonNull(
			get(sdk, "status"), getNested(sdk, "data", "status"), get(sdk, "result"), getNested(sdk, "data", "result")
		));
		resp.put("raw_response", sdk);
		return ResponseEntity.ok(resp);
	}

	@GetMapping("/status")
	public ResponseEntity<?> status(@RequestParam("gid") String gid) {
		if (!StringUtils.hasText(gid)) {
			return validationError("gid");
		}
		Map<String, Object> sdk = asMap(clientService.checkStatus(gid));
		Map<String, Object> resp = baseSuccess("Status check completed");
		resp.put("gid", firstNonNull(
			get(sdk, "gid"), getNested(sdk, "data", "gid"), get(sdk, "transactionId"), getNested(sdk, "data", "transactionId")
		));
		resp.put("transactionStatus", firstNonNull(
			get(sdk, "status"), getNested(sdk, "data", "status"), get(sdk, "result"), getNested(sdk, "data", "result"),
			get(sdk, "transactionStatus"), getNested(sdk, "data", "transactionStatus")
		));
		resp.put("raw_response", sdk);
		return ResponseEntity.ok(resp);
	}

	@PostMapping("/pauseActivate")
	public ResponseEntity<?> pauseActivate(@RequestBody Map<String, Object> body) {
		Object standingInstruction = body.get("standingInstruction");
		if (standingInstruction == null) {
			return validationError("standingInstruction");
		}
		Map<String, Object> sdk = asMap(clientService.initiateSiPayment(body));
		Map<String, Object> resp = baseSuccess("SI update completed");
		resp.put("mandateId", firstNonNull(
			get(sdk, "mandateId"), getNested(sdk, "data", "mandateId"), getNested(sdk, "standingInstruction", "mandateId")
		));
		resp.put("transactionStatus", firstNonNull(
			get(sdk, "status"), getNested(sdk, "data", "status"), get(sdk, "result"), getNested(sdk, "data", "result")
		));
		resp.put("raw_response", sdk);
		return ResponseEntity.ok(resp);
	}

	private static Map<String, Object> formatPaymentResponse(String message, Map<String, Object> sdk) {
		Map<String, Object> resp = baseSuccess(message);
		Object paymentLink = firstNonNull(
			getNested(sdk, "data", "redirectUrl"),
			getNested(sdk, "data", "redirect_url"),
			getNested(sdk, "data", "payment_link"),
			get(sdk, "redirectUrl"),
			get(sdk, "redirect_url"),
			get(sdk, "payment_link"),
			getNested(sdk, "data", "paymentLink"),
			get(sdk, "paymentLink")
		);
		Object gid = firstNonNull(
			get(sdk, "gid"), getNested(sdk, "data", "gid"), get(sdk, "transactionId"), getNested(sdk, "data", "transactionId")
		);
		resp.put("payment_link", paymentLink);
		resp.put("gid", gid);
		resp.put("raw_response", sdk);
		return resp;
	}

	private static Map<String, Object> baseSuccess(String message) {
		Map<String, Object> res = new HashMap<>();
		res.put("status", "SUCCESS");
		res.put("message", message);
		return res;
	}

	private static Object firstNonNull(Object... vals) {
		for (Object v : vals) { if (v != null) return v; }
		return null;
	}

	@SuppressWarnings("unchecked")
	private static Map<String, Object> asMap(Object obj) {
		return (Map<String, Object>) obj;
	}

	@SuppressWarnings("unchecked")
	private static Object get(Map<String, Object> map, String key) { return map != null ? map.get(key) : null; }

	@SuppressWarnings("unchecked")
	private static Object getNested(Map<String, Object> map, String k1, String k2) {
		Object inner = get(map, k1);
		if (inner instanceof Map<?, ?>) {
			return ((Map<String, Object>) inner).get(k2);
		}
		return null;
	}

	private ResponseEntity<Map<String, Object>> validationError(String... requiredFields) {
		Map<String, Object> error = new HashMap<>();
		error.put("status", "error");
		error.put("message", "Missing required fields");
		error.put("code", "VALIDATION_ERROR");
		Map<String, Object> details = new HashMap<>();
		details.put("requiredFields", requiredFields);
		error.put("details", details);
		return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(error);
	}
} 