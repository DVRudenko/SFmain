import getDadataToken from "@salesforce/apex/DadataWebServiceImpl.getDadataToken";
const dadataUrl =
  "https://suggestions.dadata.ru/suggestions/api/4_1/rs/suggest/";

const requestDadata = (source, searchString) => {
  return new Promise((resolve) => {
    getDadataToken()
      .then((result) => {
        if (result && result.length > 0) {
          resolve(makeCallout(source, searchString, result));
        } else {
          resolve(null);
        }
      })
      .catch(() => {
        resolve(null);
      });
  });
};

const makeCallout = async (source, searchString, dadataAPIToken) => {
  const response = await fetch(dadataUrl + source, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Accept: "application/json",
      Authorization: "Token " + dadataAPIToken
    },
    body: JSON.stringify({ query: searchString })
  });
  return await response.text();
};

const DADATA_METODS = {
  bank: "bank",
  address: "address"
};

export { DADATA_METODS, requestDadata };