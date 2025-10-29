import { Zap, Search, TrendingUp, Shield, Layers, DollarSign } from "lucide-react";
import { Card } from "./ui/card";

const features = [
  {
    icon: Zap,
    title: "Quick Add",
    description: "Capture expenses in two taps. Fast, intuitive, and designed for daily use.",
    color: "bg-[#5856D6]/10 text-[#5856D6]"
  },
  {
    icon: Search,
    title: "Powerful Search & Filters",
    description: "Find any transaction instantly with smart search and flexible filtering options.",
    color: "bg-[#7C7FFF]/10 text-[#7C7FFF]"
  },
  {
    icon: TrendingUp,
    title: "Monthly Summaries",
    description: "Visual charts that reveal spending patterns and help you understand your finances.",
    color: "bg-[#10B981]/10 text-[#10B981]"
  },
  {
    icon: Shield,
    title: "Privacy First",
    description: "All data stays on your device. No cloud sync, no tracking, complete privacy.",
    color: "bg-[#3B82F6]/10 text-[#3B82F6]"
  },
  {
    icon: Layers,
    title: "Categories & Tags",
    description: "Organize expenses with multiple categories and custom tags for better insights.",
    color: "bg-[#8B5CF6]/10 text-[#8B5CF6]"
  },
  {
    icon: DollarSign,
    title: "Multi-Currency Support",
    description: "Track expenses in any currency with flexible formatting options and proper symbol display.",
    color: "bg-[#F59E0B]/10 text-[#F59E0B]"
  }
];

export function Features() {
  return (
    <section id="features" className="px-6 py-16 md:py-24 bg-white">
      <div className="mx-auto max-w-7xl">
        <div className="text-center space-y-4 mb-12 md:mb-16">
          <div className="inline-block rounded-full bg-[#5856D6]/10 px-4 py-1.5 border border-[#5856D6]/20">
            <span className="text-sm text-[#5856D6]">Features</span>
          </div>
          <h2 className="text-3xl md:text-4xl lg:text-5xl text-foreground">
            Everything you need to manage expenses
          </h2>
          <p className="text-lg md:text-xl text-secondary max-w-2xl mx-auto">
            Powerful features that make expense tracking effortless
          </p>
        </div>
        
        <div className="grid gap-6 md:gap-8 md:grid-cols-2 lg:grid-cols-3">
          {features.map((feature, index) => (
            <Card 
              key={index} 
              className="p-6 md:p-8 hover:shadow-xl transition-all duration-300 border-border rounded-2xl bg-card group hover:-translate-y-1"
            >
              <div className={`inline-flex p-3 rounded-xl ${feature.color} mb-4 group-hover:scale-110 transition-transform duration-300`}>
                <feature.icon className="h-6 w-6" />
              </div>
              <h3 className="text-xl text-foreground mb-3">{feature.title}</h3>
              <p className="text-secondary">{feature.description}</p>
            </Card>
          ))}
        </div>
      </div>
    </section>
  );
}
