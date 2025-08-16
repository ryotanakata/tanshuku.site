import { gsap } from "gsap";
import { useCallback, useEffect, useRef } from "react";
import { toggleScrollLock } from "@/utils/toggleScrollLock";

/**
 * Dialogタグの開閉を制御するカスタムフック
 * Dialog自体をオーバーレイとして扱い、中のコンテンツ本来のdialogのように扱う（backdropでdialogを閉じるため）
 * @param options
 */
const useDialog = (
  options: {
    overlayColor?: string;
  } = {}
) => {
  const { overlayColor = "rgba(var(--t-color-white-default-rgb), 0.2)" } =
    options;
  const dialogRef = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const style = {
      position: "fixed",
      top: 0,
      left: 0,
      backgroundColor: overlayColor,
      width: "100%",
      maxWidth: "none",
      height: "100%",
      maxHeight: "none",
      padding: 0,
      color: "inherit",
      border: "none",
      overflow: "visible",
      zIndex: "calc(Infinity)",
    };

    gsap.set(dialogRef.current, style);
  }, [overlayColor]);

  /**
   * モーダルを開く（optionsを引数で受取可）
   */
  const openDialog = useCallback(
    (
      options: {
        onStart?: () => void;
        onUpdate?: () => void;
        onComplete?: () => void;
        duration?: number;
      } = {}
    ) => {
      const { onStart, onUpdate, onComplete, duration = 0.25 } = options;
      const dialog = dialogRef.current;
      const config = {
        duration: duration,
        autoAlpha: 1,
        onStart: () => {
          onStart?.();
        },
        onUpdate: () => {
          onUpdate?.();
        },
        onComplete: () => {
          dialog?.showModal();
          toggleScrollLock(true);
          onComplete?.();
        },
      };

      gsap.to(dialog, config);
    },
    []
  );

  /**
   * モーダルを閉じる（optionsを引数で受取可）
   */
  const closeDialog = useCallback(
    (
      options: {
        onStart?: () => void;
        onUpdate?: () => void;
        onComplete?: () => void;
        duration?: number;
      } = {}
    ) => {
      const { onStart, onUpdate, onComplete, duration = 0.25 } = options;
      const dialog = dialogRef.current;
      const config = {
        duration: duration,
        autoAlpha: 0,
        onStart: () => {
          onStart?.();
        },
        onUpdate: () => {
          onUpdate?.();
        },
        onComplete: () => {
          dialogRef.current?.close();
          toggleScrollLock(false);
          onComplete?.();
        },
      };

      gsap.to(dialog, config);
    },
    []
  );

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        closeDialog();
      }
    };

    document.addEventListener("keydown", handleKeyDown);
    return () => {
      document.removeEventListener("keydown", handleKeyDown);
    };
  }, [closeDialog]);

  return {
    dialogRef,
    openDialog,
    closeDialog,
  };
};

export { useDialog };
