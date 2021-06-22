const uriXLS = "data:application/vnd.ms-excel;base64,";
const templateXLS =
  '<html xmlns:o="urn:schemas-microsoft-com:office:office" xmlns:x="urn:schemas-microsoft-com:office:' +
  'excel" xmlns="http://www.w3.org/TR/REC-html40"><head><xml><x:ExcelWorkbook><x:ExcelWorksheets><x:ExcelWorksheet>' +
  "<x:Name>{worksheet}</x:Name><x:WorksheetOptions><x:DisplayGridlines/></x:WorksheetOptions></x:ExcelWorksheet>" +
  '</x:ExcelWorksheets></x:ExcelWorkbook></xml><meta http-equiv="content-type" content="text/plain; charset=UTF-8"/>' +
  "</head><body>{table}</body></html>";

const exportData = (sourceComponent, fileName, worksheetName, locale) => {
  let content = buildTable(parseForm(sourceComponent), locale);
  let worksheet = { worksheet: worksheetName, table: content.outerHTML };

  let link = document.createElement("a");
  link.download = fileName + ".xls";
  link.href = uriXLS + formatData(templateXLS, worksheet);
  link.click();
};

const formatData = (template, worksheet) => {
  let formattedData = template.replace(/{(\w+)}/g, function (m, p) {
    return worksheet[p];
  });
  return btoa(unescape(encodeURIComponent(formattedData)));
};

const parseForm = (cmp) => {
  let data = {};
  let components = cmp.template.querySelectorAll(".exportable-cmp");
  if (components != null) {
    for (let component of components) {
      Object.assign(data, component.exportableFields);
    }
  }
  return data;
};

const isObject = (v) => {
  return Object.prototype.toString.call(v) === "[object Object]";
};

const buildTable = (data, locale) => {
  let table = document.createElement("table");
  let mainHeaders = document.createElement("tr");

  let name = document.createElement("td");
  name.setAttribute("bgcolor", "silver");
  name.setAttribute("align", "center");
  name.setAttribute("style", "border: medium solid black; font-weight: bold;");

  let value = document.createElement("td");
  value.setAttribute("bgcolor", "silver");
  value.setAttribute("align", "center");
  value.setAttribute("style", "border: medium solid black; font-weight: bold;");

  switch (locale) {
    case "ru": {
      name.textContent = "Имя поля";
      value.textContent = "Значение поля";
      break;
    }
    case "en": {
      name.textContent = "Field name";
      value.textContent = "Field value";
      break;
    }
    default: {
      name.textContent = "Field name";
      value.textContent = "Field value";
      break;
    }
  }

  mainHeaders.appendChild(name);
  mainHeaders.appendChild(value);
  table.appendChild(mainHeaders);

  return buildRows(table, data);
};

const buildRows = (table, data) => {
  for (let key in data) {
    if (isObject(data[key])) {
      let row = document.createElement("tr");
      let header = document.createElement("td");

      header.textContent = key;
      header.setAttribute("colspan", 2);
      header.setAttribute("bgcolor", "yellow");
      header.setAttribute("align", "center");
      header.setAttribute("style", "border: medium solid black;");

      row.appendChild(header);
      table.appendChild(row);

      buildRows(table, data[key]);
    } else {
      let row = document.createElement("tr");

      let fieldName = document.createElement("td");
      fieldName.textContent = key;

      let fieldValue = document.createElement("td");
      fieldValue.textContent = data[key];
      fieldValue.setAttribute("align", "left");

      row.appendChild(fieldName);
      row.appendChild(fieldValue);

      table.appendChild(row);
    }
  }

  return table;
};

const parseBoolean = (value, locale) => {
  if (Object.prototype.toString.call(value) != "[object Boolean]") return value;
  switch (locale) {
    case "ru": {
      return value ? "Да" : "Нет";
    }
    case "en": {
      return value ? "Yes" : "No";
    }
    default:
      return value ? "Yes" : "No";
  }
};

const parseComponent = (cmp, locale) => {
  let data = {};
  let fields = cmp.template.querySelectorAll(".exportable-field");
  let header = cmp.template.querySelector(".exportable-header");
  if (fields != null) {
    for (let field of fields) {
      if (field.label != null) {
        Object.defineProperty(data, field.label, {
          enumerable: true,
          configurable: true,
          writable: true,
          value: field.classList.contains("exportable-boolean")
            ? parseBoolean(field.checked, locale)
            : field.value
        });
      }
    }
  }
  if (header != null) {
    let result = {};
    Object.defineProperty(result, header.textContent, {
      enumerable: true,
      configurable: true,
      writable: true,
      value: data
    });
    return result;
  }
  return data;
};

export { exportData, parseComponent };
