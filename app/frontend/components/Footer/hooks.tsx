import { useHaptic } from "react-haptic";
import { TERMS } from "@/constants/termsConstant";
import { useDialog } from "@/hooks/useDialog";

const useFooterHooks = () => {
  const year = new Date().getFullYear();
  const { dialogRef, openDialog, closeDialog } = useDialog();
  const [y, m, d] = TERMS.LAST_UPDATED.split("-");
  const { vibrate } = useHaptic();
  const handleClickCloseButton = () => {
    vibrate();
    closeDialog();
  };
  const handleClickTermsButton = () => {
    vibrate();
    openDialog();
  };

  return {
    year,
    y,
    m,
    d,
    dialogRef,
    handleClickCloseButton,
    handleClickTermsButton,
  };
};

export { useFooterHooks };
