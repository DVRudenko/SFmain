//VERSION - 1.0

/* eslint-disable no-console */
import { LightningElement, api } from 'lwc';
import { normalizeBoolean, normalizeString, configToString } from './helper';

const VARIABLES = {
    ARROW_SIZE: 8,
    PADDING_SIZE: 4
};

const VARIANTS = {
    SMALL: 'small',
    LARGE: 'large'
};

const CLASSES = {
    ARROW: '.fltbase-tooltip__arrow',
    CONTENT: '.fltbase-tooltip__content',
};

export default class FltbaseTooltip extends LightningElement {
    @api value;
    @api variant;
    @api maxWidth = 300;
    @api minWidth = 100;
    @api whiteBackground;

    renderedCallback () {
        let content = this.template.querySelector(CLASSES.CONTENT);
        let minWidth = content.offsetWidth < this.minWidth ? this.minWidth : content.offsetWidth;
        // eslint-disable-next-line @lwc/lwc/no-inner-html
        content.innerHTML = this.value;
        content.style.maxWidth = this.maxWidth + 'px';
        content.style.minWidth = minWidth + 'px';

        let element = this.template.querySelector('div');
        this.setPosition(element);
        this.setPosition(element);
    }

    handleMouseOver (event) {
        let element = event.target;
        this.stopEvent(event);
        this.setPosition(element);
        this.setPosition(element);
    }

    setPosition (element) {
        let elemRect = element.getBoundingClientRect();
        let elementRight = document.documentElement.clientWidth - elemRect.left - element.offsetWidth;
        let arrowElement = this.template.querySelector(CLASSES.ARROW);
        let content = this.template.querySelector(CLASSES.CONTENT);

        // top or bottom
        if (elemRect.top - VARIABLES.ARROW_SIZE * 2 >= content.offsetHeight) {
            content.style.top = (element.offsetTop - content.offsetHeight - VARIABLES.ARROW_SIZE * 2) + "px";
            arrowElement.style.top = (element.offsetTop - arrowElement.offsetHeight / 2 - VARIABLES.ARROW_SIZE) + "px";
            arrowElement.style.left = (element.offsetLeft + element.offsetWidth / 2 - arrowElement.offsetWidth / 2) + "px";
            arrowElement.style.border = VARIABLES.ARROW_SIZE + "px solid transparent";
            arrowElement.style.borderTop = VARIABLES.ARROW_SIZE + "px solid #FFFFFF";
        }
        else {
            content.style.top = (element.offsetTop + element.offsetHeight + VARIABLES.ARROW_SIZE * 2) + "px";
            arrowElement.style.top = (element.offsetTop + element.offsetHeight + VARIABLES.ARROW_SIZE - arrowElement.offsetHeight / 2) + "px";
            arrowElement.style.left = (element.offsetLeft + element.offsetWidth / 2 - arrowElement.offsetWidth / 2) + "px";
            arrowElement.style.border = VARIABLES.ARROW_SIZE + "px solid transparent";
            arrowElement.style.borderBottom = VARIABLES.ARROW_SIZE + "px solid #FFFFFF";
        }

        // left-right alignment
        if (elemRect.left < content.offsetWidth / 2) {
            content.style.left = VARIABLES.PADDING_SIZE + "px";
        }
        else if (elementRight < content.offsetWidth / 2) {
            content.style.right = VARIABLES.PADDING_SIZE + "px";
            content.style.left = 'auto';
        }
        else {
            content.style.left = (element.offsetLeft + element.offsetWidth / 2 - content.offsetWidth / 2) + "px";
        }
    }

    stopEvent (event) {
        event.stopImmediatePropagation();
    }

    get computedElementClass () {
        return configToString({
            'fltbase-tooltip': true,
            'fltbase-tooltip_small': this.normalizedVariant === VARIANTS.SMALL,
            'fltbase-tooltip_large': this.normalizedVariant === VARIANTS.LARGE,
            'fltbase-tooltip__button-unfocused': normalizeBoolean(this.whiteBackground)
        });
    }

    get normalizedVariant () {
        return normalizeString(this.variant, {
            fallbackValue: VARIANTS.SMALL,
            validValues: [
                VARIANTS.LARGE,
                VARIANTS.SMALL,
            ]
        });
    }
}