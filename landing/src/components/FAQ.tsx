import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "./ui/accordion";

const faqs = [
  {
    question: "Is my data stored locally?",
    answer: "Yes! All your financial data stays on your device. Munshi doesn't use any cloud services or external servers, ensuring complete privacy and control over your information."
  },
  {
    question: "Is there a cloud backup option?",
    answer: "Currently, Munshi focuses on local-first privacy. While there's no cloud backup, you can export your data as a backup file and restore it when needed."
  },
  {
    question: "Which currencies are supported?",
    answer: "Munshi supports multiple currencies with flexible formatting options. You can track expenses in any currency including USD, EUR, GBP, INR, and many more with proper symbol display."
  },
  {
    question: "Does it cost anything?",
    answer: "Munshi is completely free and open source under the MIT license. There are no hidden costs, subscriptions, or in-app purchases. You can even contribute to its development on GitHub!"
  },
  {
    question: "Is it available for iOS?",
    answer: "Munshi is built with Flutter, which supports both Android and iOS. Check the GitHub repository for the latest information on platform availability and releases."
  },
  {
    question: "Can I contribute or report bugs?",
    answer: "Absolutely! Munshi is open source. You can report bugs, request features, or contribute code through the GitHub repository at github.com/pratham-sarankar/munshi."
  }
];

export function FAQ() {
  return (
    <section id="faq" className="px-6 py-16 md:py-24 bg-gradient-to-b from-white to-[#FAFAFB]">
      <div className="mx-auto max-w-3xl">
        <div className="text-center space-y-4 mb-12 md:mb-16">
          <div className="inline-block rounded-full bg-[#5856D6]/10 px-4 py-1.5 border border-[#5856D6]/20">
            <span className="text-sm text-[#5856D6]">FAQ</span>
          </div>
          <h2 className="text-3xl md:text-4xl lg:text-5xl text-foreground">
            Frequently asked questions
          </h2>
          <p className="text-lg md:text-xl text-secondary">
            Everything you need to know about Munshi
          </p>
        </div>
        
        <Accordion type="single" collapsible className="space-y-4">
          {faqs.map((faq, index) => (
            <AccordionItem 
              key={index} 
              value={`item-${index}`}
              className="border border-border rounded-2xl px-6 bg-white shadow-sm hover:shadow-md transition-shadow"
            >
              <AccordionTrigger className="text-left hover:no-underline py-6">
                <span className="text-foreground pr-4">{faq.question}</span>
              </AccordionTrigger>
              <AccordionContent className="text-secondary pb-6">
                {faq.answer}
              </AccordionContent>
            </AccordionItem>
          ))}
        </Accordion>
      </div>
    </section>
  );
}
