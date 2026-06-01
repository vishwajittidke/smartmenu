public with sharing class BusinessException extends Exception {
    // Custom exception class for domain-level business rule violations.
    // Ensures consistent error handling across the service and domain layers.

    /** Returns custom error code for client routing */
    public String getErrorCode() {
        return 'BUSINESS_VALIDATION_ERROR';
    }
}
