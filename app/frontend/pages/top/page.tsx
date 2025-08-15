import { Form } from "@/components/Main/Form";
import { Mv } from "@/components/Main/Mv";
import { Footer } from "@/components/Footer";
import { Header } from "@/components/Header";
import { Main } from "@/components/Main";

export default function TopPage() {
  return (
    <>
      <Header />
      <Main>
        <Mv />
        <Form />
      </Main>
      <Footer />
    </>
  )
}