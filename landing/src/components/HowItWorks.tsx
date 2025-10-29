import { PlusCircle, Tag, BarChart3 } from "lucide-react";

const steps = [
  {
    number: "01",
    icon: PlusCircle,
    title: "Add Transaction",
    description: "Quickly add your expense with amount, category, and optional notes."
  },
  {
    number: "02",
    icon: Tag,
    title: "Categorize & Tag",
    description: "Organize with smart categories and custom tags for better tracking."
  },
  {
    number: "03",
    icon: BarChart3,
    title: "Review Monthly Summary",
    description: "View beautiful charts and insights to understand your spending patterns."
  }
];

export function HowItWorks() {
  return (
    <section id="how-it-works" className="px-6 py-16 md:py-24 bg-gradient-to-b from-[#FAFAFB] to-white">
      <div className="mx-auto max-w-7xl">
        <div className="text-center space-y-4 mb-12 md:mb-16">
          <div className="inline-block rounded-full bg-[#5856D6]/10 px-4 py-1.5 border border-[#5856D6]/20">
            <span className="text-sm text-[#5856D6]">How It Works</span>
          </div>
          <h2 className="text-3xl md:text-4xl lg:text-5xl text-foreground">
            Simple workflow, powerful results
          </h2>
          <p className="text-lg md:text-xl text-secondary max-w-2xl mx-auto">
            Track your expenses in three simple steps
          </p>
        </div>
        
        <div className="grid gap-8 md:gap-12 md:grid-cols-3 relative">
          {/* Connecting line for desktop */}
          <div className="hidden md:block absolute top-16 left-0 right-0 h-0.5 bg-gradient-to-r from-transparent via-[#5856D6]/30 to-transparent"></div>
          
          {steps.map((step, index) => (
            <div key={index} className="relative text-center">
              <div className="inline-flex items-center justify-center w-16 h-16 md:w-20 md:h-20 rounded-2xl bg-gradient-to-br from-[#5856D6] to-[#4845B8] text-white mb-6 shadow-lg shadow-[#5856D6]/30 relative z-10">
                <step.icon className="h-8 w-8 md:h-10 md:w-10" />
              </div>
              <div className="absolute top-3 md:top-6 left-1/2 -translate-x-1/2 text-6xl md:text-8xl opacity-5 -z-10 text-[#5856D6]">
                {step.number}
              </div>
              <h3 className="text-xl md:text-2xl text-foreground mb-3">{step.title}</h3>
              <p className="text-secondary max-w-sm mx-auto">{step.description}</p>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
}
