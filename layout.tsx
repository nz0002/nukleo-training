import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = {
  title: "NUKLEO TRAINING | Equipaciones deportivas personalizadas",
  description: "Ropa deportiva personalizada para gimnasios, clubes y deportes de contacto. Solicita tu presupuesto a NUKLEO TRAINING.",
  metadataBase: new URL("https://example.com"),
  robots: { index: true, follow: true }
};
export default function RootLayout({children}:{children:React.ReactNode}) {
  return <html lang="es"><body>{children}</body></html>;
}
