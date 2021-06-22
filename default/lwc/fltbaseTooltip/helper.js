export function normalizeString (value, config) {
    let normalized = (typeof value === 'string' && value.trim()) || '';
    normalized = normalized.toLowerCase();
    if (config.validValues && !config.validValues.includes(normalized)) {
        normalized = config.fallbackValue;
    }

    return normalized;
}

export function normalizeBoolean(value) {
    let re = new RegExp('^true$', 'i');
    return re.test(value);
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