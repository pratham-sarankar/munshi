import { Card } from "./ui/card";
import { Star } from "lucide-react";
import { Button } from "./ui/button";

const testimonials = [
  {
    name: "Priya Sharma",
    role: "Freelance Designer, Mumbai",
    content: "Finally, an expense tracker that respects my privacy! The local-first approach and beautiful design make it perfect for daily use.",
    rating: 5
  },
  {
    name: "Rahul Verma",
    role: "Software Engineer, Bangalore",
    content: "As a developer, I appreciate the open-source nature. The flexible currency support and quick add features are exactly what I needed.",
    rating: 5
  },
  {
    name: "Ananya Patel",
    role: "Student, Delhi",
    content: "Simple, fast, and effective. I love how I can categorize expenses and see monthly trends without any complicated setup.",
    rating: 5
  }
];

export function Testimonials() {
  return (
    <section className="px-6 py-16 md:py-24 bg-white">
      <div className="mx-auto max-w-7xl">
        <div className="text-center space-y-4 mb-12 md:mb-16">
          <div className="inline-block rounded-full bg-[#5856D6]/10 px-4 py-1.5 border border-[#5856D6]/20">
            <span className="text-sm text-[#5856D6]">Testimonials</span>
          </div>
          <h2 className="text-3xl md:text-4xl lg:text-5xl text-foreground">
            Loved by users worldwide
          </h2>
          <p className="text-lg md:text-xl text-secondary max-w-2xl mx-auto">
            See what people are saying about Munshi
          </p>
        </div>
        
        <div className="grid gap-6 md:gap-8 md:grid-cols-3 mb-12">
          {testimonials.map((testimonial, index) => (
            <Card key={index} className="p-6 md:p-8 border-border rounded-2xl hover:shadow-xl transition-all duration-300 bg-card">
              <div className="flex gap-1 mb-4">
                {[...Array(testimonial.rating)].map((_, i) => (
                  <Star key={i} className="h-5 w-5 fill-[#7C7FFF] text-[#7C7FFF]" />
                ))}
              </div>
              <p className="text-foreground mb-6 italic">"{testimonial.content}"</p>
              <div>
                <div className="text-foreground">{testimonial.name}</div>
                <div className="text-sm text-secondary">{testimonial.role}</div>
              </div>
            </Card>
          ))}
        </div>
        
        <div className="text-center">
          <Button 
            variant="outline" 
            className="border-[#5856D6] text-[#5856D6] hover:bg-[#5856D6]/5 rounded-xl"
          >
            Submit Your Testimonial
          </Button>
        </div>
      </div>
    </section>
  );
}
