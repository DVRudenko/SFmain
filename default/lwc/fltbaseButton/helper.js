export function normalizeString (value, config) {
    let normalized = (typeof value === 'string' && value.trim()) || '';
    normalized = normalized.toLowerCase();
    if (config.validValues && !config.validValues.includes(normalized)) {
        normalized = config.fallbackValue;
    }

    return normalized;
}

export function normalizeInteger (value) {
    let length = parseInt(value, 10);
    let isInteger = Number.isInteger(length);
    return isInteger ? length : null;
}

export function configToString (config) {
    let arr = [];
    for (let nextClassName in config) {
        if (config.hasOwnProperty(nextClassName) && config[nextClassName]) {
            arr.push(nextClassName);
        }
    }

    return arr.join(' ');
}