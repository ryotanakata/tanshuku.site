import {
  Children,
  ReactElement,
  ReactNode,
  cloneElement,
  isValidElement,
} from "react";
import styles from "@/components/Main/style.module.scss";

const Main = ({ children }: { children: ReactNode }) => {
  let divContent: ReactNode[] = [];

  return (
    <main className={styles.main}>
      <div>
        {Children.map(children, (child, i) => {
          if (child && isValidElement(child)) {
            const childWithProps = child as ReactElement<{
              includeInner?: boolean;
            }>;
            const useInner =
              childWithProps.props.includeInner !== undefined
                ? childWithProps.props.includeInner
                : true;

            const clonedChild = cloneElement(childWithProps, {
              includeInner: useInner,
              key: i,
            });

            if (useInner) {
              divContent.push(clonedChild);
              return null;
            } else {
              if (divContent.length > 0) {
                const content = (
                  <>
                    <div className={styles.inner}>{divContent}</div>
                    {clonedChild}
                  </>
                );
                divContent = [];
                return content;
              } else {
                return clonedChild;
              }
            }
          }
          return null;
        })}
        {divContent.length > 0 && (
          <div className={styles.inner}>{divContent}</div>
        )}
      </div>
    </main>
  );
};

export { Main };
