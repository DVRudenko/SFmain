const checkComponentValidityForSaving = (template, canBeEmpty) => {
  for (let element of template.querySelectorAll("lightning-input")) {
    if (!element.checkValidity() && (!canBeEmpty || (element.value != ""))) {
      return false;
    }
  }

  for (let element of template.querySelectorAll("lightning-textarea")) {
    if (!element.checkValidity() && (!canBeEmpty || (element.value != ""))) {
      return false;
    }
  }
  for (let element of template.querySelectorAll("lightning-combobox")) {
    if (!element.checkValidity() && (!canBeEmpty || (element.value != ""))) {
      return false;
    }
  }
  return true;
};

const getInavlidForSavingSections = (template, childToLabelMap, canBeEmpty) => {
  let invalidSections = [];
  for (let child of Array.from(childToLabelMap.keys())) {
    let isValidForSaving = template
      .querySelector(child)
      .checkValidityForSaving(canBeEmpty);
    if (!isValidForSaving) {
      invalidSections.push(childToLabelMap.get(child));
    }
  }
  return invalidSections;
};

export { checkComponentValidityForSaving, getInavlidForSavingSections };