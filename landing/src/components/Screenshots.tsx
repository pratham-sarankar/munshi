import { ImageWithFallback } from "./figma/ImageWithFallback";
import { Card } from "./ui/card";

const screenshots = [
  {
    title: "Dashboard",
    description: "Get a quick overview of your expenses",
    image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaW5hbmNpYWwlMjBkYXNoYm9hcmR8ZW58MXx8fHwxNzYxNjM1Nzc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    title: "Transactions",
    description: "View and manage all your transactions",
    image: "https://images.unsplash.com/photo-1610568711980-a3679fcdeef3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxtb2JpbGUlMjBleHBlbnNlJTIwdHJhY2tpbmd8ZW58MXx8fHwxNzYxNjg0Njg5fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  },
  {
    title: "Analytics",
    description: "Beautiful charts and insights",
    image: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmaW5hbmNpYWwlMjBkYXNoYm9hcmR8ZW58MXx8fHwxNzYxNjM1Nzc1fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
  }
];

export function Screenshots() {
  return (
    <section id="screenshots" className="px-6 py-16 md:py-24 bg-white">
      <div className="mx-auto max-w-7xl">
        <div className="text-center space-y-4 mb-12 md:mb-16">
          <div className="inline-block rounded-full bg-[#5856D6]/10 px-4 py-1.5 border border-[#5856D6]/20">
            <span className="text-sm text-[#5856D6]">Screenshots</span>
          </div>
          <h2 className="text-3xl md:text-4xl lg:text-5xl text-foreground">
            See Munshi in action
          </h2>
          <p className="text-lg md:text-xl text-secondary max-w-2xl mx-auto">
            A clean, beautiful interface designed for daily use
          </p>
        </div>
        
        <div className="grid gap-8 md:grid-cols-3">
          {screenshots.map((screenshot, index) => (
            <Card 
              key={index} 
              className="p-6 border-border rounded-2xl bg-card hover:shadow-xl transition-all duration-300 group overflow-hidden"
            >
              <div className="relative mb-4 rounded-xl overflow-hidden bg-gradient-to-br from-[#5856D6]/10 to-[#7C7FFF]/10 aspect-[9/16]">
                <ImageWithFallback
                  src={screenshot.image}
                  alt={screenshot.title}
                  className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
                />
              </div>
              <h3 className="text-xl text-foreground mb-2">{screenshot.title}</h3>
              <p className="text-sm text-secondary">{screenshot.description}</p>
            </Card>
          ))}
        </div>
      </div>
    </section>
  );
}
