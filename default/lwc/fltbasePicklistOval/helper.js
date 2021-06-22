export function normalizeInteger (value) {
    let length = parseInt(value, 10);
    let isInteger = Number.isInteger(length);
    return isInteger ? length : null;
}

export function normalizeBoolean(value) {
    let re = /^true$/i;
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