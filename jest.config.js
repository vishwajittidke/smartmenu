const { jestConfig } = require('@salesforce/sfdx-lwc-jest/config');
module.exports = {
    ...jestConfig,
    moduleNameMapper: {
        '^@salesforce/apex$': '<rootDir>/force-app/test/jest-mocks/apex',
        '^@salesforce/apex/(.*)$': '<rootDir>/force-app/test/jest-mocks/apex/$1',
        '^lightning/(.*)$': '<rootDir>/force-app/test/jest-mocks/lightning/$1'
    }
};
