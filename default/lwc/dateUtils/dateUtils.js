const getFormattedDate = (locale) => {
  let date = new Date();
  switch (locale) {
    case "ru": {
      let dd = date.getDate();
      if (dd < 10) {
        dd = "0" + dd;
      }

      let mm = date.getMonth() + 1;
      if (mm < 10) {
        mm = "0" + mm;
      }

      return dd + "." + mm + "." + date.getFullYear();
    }
    default:
      return getFormattedDate("ru");
  }
};

export { getFormattedDate };
