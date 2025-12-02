const { validateRequiredFields } = require('../utils/validators');
const { validateHierarchicalPlacement } = require('../utils/schemaValidator');
const { logger } = require('../utils/logger');

/**
 * Simple validation function
 * @param {Object} payload - Payload to validate
 * @param {Object} options - Validation options
 * @param {Array<string>} options.requiredFields - Array of required field paths
 * @param {boolean} options.validateSchema - Whether to validate schema (default: true)
 * @returns {void}
 */

function validatePayload(payload, options = {}) {
  const {
    requiredFields = [],
    // Disable schema validation by default; only do hierarchy checks per requirement
    validateSchema = false,
    validateHierarchy = true,
    operationType,
    conditionalValidation
  } = options;

  try {
    // 1. All Required Fields Validation (SECOND - to catch missing service-specific fields)
    if (requiredFields && requiredFields.length > 0) {
      const validationData = {};
      requiredFields.forEach(field => {
        const keys = field.split('.');
        let value = payload;
        for (const key of keys) {
          value = value?.[key];
        }
        validationData[field] = value;
      });
      
      validateRequiredFields(validationData, requiredFields);
    }

  // 2. Operation Type Validation (THIRD - to validate specific operation types)
    if (operationType) {
      const { field, validTypes = [] } = operationType;
      const typeValue = field.split('.').reduce((obj, key) => obj?.[key], payload);
      if (!validTypes.includes(typeValue)) {
        throw new Error(
          `Invalid value for ${field}: ${typeValue}. Expected one of: ${validTypes.join(', ')}`
        );
      }
    }
     
    // 3. Conditional Field Validation
    if (conditionalValidation) {
      const { condition, value, requiredFields: conditionalFields } = conditionalValidation;
      const actual = condition.split('.').reduce((obj, key) => obj?.[key], payload);

      if (actual === value && conditionalFields && conditionalFields.length > 0) {
        const conditionalData = {};
        conditionalFields.forEach(field => {
          const keys = field.split('.');
          let val = payload;
          for (const key of keys) {
            val = val?.[key];
          }
          conditionalData[field] = val;
        });
        validateRequiredFields(conditionalData, conditionalFields);
      }
    }


    // 4. Hierarchical placement validation (warnings only)
    if (validateHierarchy) {
      const result = validateHierarchicalPlacement(payload);
      if (result?.warnings?.length) {
        logger.warn('Hierarchical placement warnings detected', {
          warningCount: result.warnings.length,
          warnings: result.warnings
        });
      }
    }
    logger.debug('Validation passed');
  } catch (error) {
    // Let the original error bubble up to avoid duplicate logs and stack traces
    throw error;
  }
}

module.exports = {
  validatePayload
}; 