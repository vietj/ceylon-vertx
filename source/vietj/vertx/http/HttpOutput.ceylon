shared interface HttpOutput<H> given H satisfies HttpOutput {
	
	shared formal H contentType(String mimeType, String charset = "UTF-8");
	
	
}