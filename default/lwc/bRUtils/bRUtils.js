import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import BR_SETTINGS_LIST from "@salesforce/label/c.BR_settings_list_label";
import SYSTEM_EXCEPTION from "@salesforce/label/c.System_exception";
import DELETE_SETTING from "@salesforce/label/c.DeleteSetting";
import RESULT_OK from "@salesforce/label/c.ResultOK";
import CANCEL from "@salesforce/label/c.Cancel";
import DELETE_MESSAGE from "@salesforce/label/c.DeleteMessage";
import TOST_DELETE_MESSAGE from "@salesforce/label/c.TostDeleteMessage";
import TOST_SUCCESS_MESSAGE from "@salesforce/label/c.TostSuccessMessage";
import CLOSE_MODAL from "@salesforce/label/c.CloseModal";
import BR_SETTING_PAGE from "@salesforce/label/c.BR_Setting_Page";
import BR_SETTING_ACTIVE from "@salesforce/label/c.Setting_active";
import BR_SETTING_NAME from "@salesforce/label/c.Setting_Name";
import BR_SETTING_OBJECT_NAME from "@salesforce/label/c.Object_Name";
import BR_SETTING_RESULT_STATUS from "@salesforce/label/c.Result_Status";
import BR_BUTTON_VIEW from "@salesforce/label/c.View_BR";
import BR_BUTTON_ADD_NEW_SETTING from "@salesforce/label/c.Add_new_BR_setting";
import BR_BUTTON_BACK from "@salesforce/label/c.BR_setting_back";
import BR_BUTTON_SAVE from "@salesforce/label/dsfs.Save";
import BR_BUTTON_EDIT from "@salesforce/label/dsfs.Edit";
import BR_BUTTON_CANCEL from "@salesforce/label/dsfs.Cancel";
import BR_SETTING_SAVE_SUCCESSFULLY from "@salesforce/label/dsfs.SettingsSavedSuccessfully";

const BR_LABELS = {
      BR_SETTINGS_LIST,
      SYSTEM_EXCEPTION,
      DELETE_SETTING,
      RESULT_OK,
      CANCEL,
      DELETE_MESSAGE,
      TOST_DELETE_MESSAGE,
      TOST_SUCCESS_MESSAGE,
      CLOSE_MODAL,
      BR_SETTING_PAGE,
      BR_SETTING_ACTIVE,
      BR_SETTING_NAME,
      BR_SETTING_OBJECT_NAME,
      BR_SETTING_RESULT_STATUS,
      BR_BUTTON_VIEW,
      BR_BUTTON_ADD_NEW_SETTING,
      BR_BUTTON_BACK,
      BR_BUTTON_SAVE,
      BR_BUTTON_EDIT,
      BR_BUTTON_CANCEL,
      BR_SETTING_SAVE_SUCCESSFULLY
};

class BRUtils {

}

const handleError = (title, error) => {
      const notificationError = new ShowToastEvent({
            title,
            message: error,
            variant: "error"
      });
     dispatchEvent(notificationError);
};

const handleSuccess = (title, message) => {
      const notificationSuccess = new ShowToastEvent({
            title,
            message,
            variant: "success"
      });
      dispatchEvent(notificationSuccess);
};

export { BRUtils, BR_LABELS, handleError, handleSuccess }