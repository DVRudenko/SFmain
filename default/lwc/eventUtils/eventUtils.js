const dispatchCustomEvent = (component, name, detail) => {
    if (detail == undefined) {
        component.dispatchEvent(
            new CustomEvent(name)
        );
    } else {
        component.dispatchEvent(
            new CustomEvent(
                name,
                detail
            )
        );
    }
}

export { dispatchCustomEvent }