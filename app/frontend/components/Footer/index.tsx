import { TERMS } from "@/constants/termsConstant";
import { useDialog } from "@/hooks/useDialog";
import styles from "@/components/Footer/style.module.scss";

const Footer = () => {
  const year = new Date().getFullYear();
  const { dialogRef, openDialog, closeDialog } = useDialog();
  const [y, m, d] = TERMS.LAST_UPDATED.split("-");

  return (
    <footer className={styles.footer}>
      <div>
        <div className={styles.terms}>
          <button onClick={() => openDialog()}>利用規約</button>

          <dialog ref={dialogRef} onClick={() => closeDialog()}>
            <div>
              <div>
                <div tabIndex={0} className={styles.content}>
                  <h2>利用規約</h2>
                  <p>
                    最終更新日：
                    <time dateTime={TERMS.LAST_UPDATED}>
                      {y}年{m}月{d}日
                    </time>
                  </p>
                  <dl>
                    {TERMS.SECTIONS.map((section, i) => (
                      <div key={i}>
                        <dt>{section.TITLE}</dt>
                        <dd>
                          {section.CONTENT?.map((text, j) => (
                            <p key={j}>{text}</p>
                          ))}
                          {section.CATEGORIES && (
                            <dl>
                              {section.CATEGORIES.map((category, k) => (
                                <div key={k}>
                                  <dt>{category.TITLE}</dt>
                                  <dd>
                                    <ul>
                                      {category.ITEMS.map((item, l) => (
                                        <li key={l}>{item}</li>
                                      ))}
                                    </ul>
                                  </dd>
                                </div>
                              ))}
                            </dl>
                          )}
                        </dd>
                      </div>
                    ))}
                  </dl>
                  <div className={styles.button}>
                    <button onClick={() => closeDialog()}>閉じる</button>
                  </div>
                </div>
              </div>
            </div>
          </dialog>
        </div>
        <div className={styles.copyright}>
          <p>
            &copy;{year} <span translate="no">tanshuku</span> -
            シンプルな国産URL短縮サービス
          </p>
        </div>
      </div>
    </footer>
  );
};

export { Footer };
