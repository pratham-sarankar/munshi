import { Button } from "./ui/button";
import { Download, Github, Play } from "lucide-react";
import { ImageWithFallback } from "./figma/ImageWithFallback";
import logo from "../assets/logo.png";

export function Hero() {
  return (
    <section className="relative overflow-hidden bg-gradient-to-b from-[#FAFAFB] to-white px-6 py-16 md:py-24">
      {/* Decorative background elements */}
      <div className="absolute top-20 right-0 w-96 h-96 bg-[#5856D6]/5 rounded-full blur-3xl"></div>
      <div className="absolute bottom-0 left-0 w-96 h-96 bg-[#7C7FFF]/5 rounded-full blur-3xl"></div>
      
      <div className="mx-auto max-w-7xl relative">
        <div className="grid gap-12 lg:grid-cols-2 lg:gap-16 items-center">
          <div className="space-y-6 md:space-y-8">
            <div className="inline-flex items-center gap-2 rounded-full bg-[#5856D6]/10 px-4 py-2 border border-[#5856D6]/20">
              <span className="w-2 h-2 bg-[#5856D6] rounded-full animate-pulse"></span>
              <span className="text-sm text-[#5856D6]">Built with Flutter</span>
            </div>
            
            <div className="space-y-4">
              <h1 className="text-4xl md:text-5xl lg:text-6xl text-foreground">
                Track your spending.
                <br />
                <span className="text-[#5856D6]">Save more.</span>
                <br />
                <span className="text-[#7C7FFF]">Stress less.</span>
              </h1>
              
              <p className="text-lg md:text-xl text-secondary max-w-xl">
                Munshi is a lightweight personal finance app with beautiful animations, 
                fast search, and easy categorization. Track expenses in any currency with ease.
              </p>
            </div>
            
            <div className="flex flex-col sm:flex-row gap-4">
              <Button 
                size="lg" 
                className="bg-[#5856D6] hover:bg-[#4845B8] text-white shadow-lg shadow-[#5856D6]/20 rounded-xl px-8"
              >
                <Download className="mr-2 h-5 w-5" />
                Download on Google Play
              </Button>
              <a 
                href="https://github.com/pratham-sarankar/munshi" 
                target="_blank" 
                rel="noopener noreferrer"
              >
                <Button 
                  size="lg" 
                  variant="outline" 
                  className="w-full border-[#5856D6] text-[#5856D6] hover:bg-[#5856D6]/5 hover:text-[#5856D6] rounded-xl px-8"
                >
                  <Github className="mr-2 h-5 w-5" />
                  View on GitHub
                </Button>
              </a>
            </div>
            
            <div className="flex items-center gap-8 pt-4">
              <div>
                <div className="text-2xl md:text-3xl text-foreground">Open Source</div>
                <div className="text-sm text-secondary">MIT License</div>
              </div>
              <div className="h-12 w-px bg-border"></div>
              <div>
                <div className="text-2xl md:text-3xl text-foreground">Privacy First</div>
                <div className="text-sm text-secondary">Data stays local</div>
              </div>
              <div className="h-12 w-px bg-border hidden sm:block"></div>
              <div className="hidden sm:block">
                <div className="text-2xl md:text-3xl text-foreground">Multi-Currency</div>
                <div className="text-sm text-secondary">Any currency</div>
              </div>
            </div>
          </div>
          
          <div className="relative">
            <div className="absolute inset-0 bg-gradient-to-br from-[#5856D6]/20 to-[#7C7FFF]/20 rounded-3xl blur-3xl"></div>
            <div className="relative bg-white rounded-3xl shadow-2xl p-8 border border-border flex items-center justify-center">
              <div className="relative w-full max-w-md aspect-square">
                <div className="absolute inset-0 bg-gradient-to-br from-[#5B5FEF] via-[#6D70E6] to-[#7C7FFF] rounded-3xl"></div>
                <div className="absolute inset-0 flex items-center justify-center">
                  <img src={logo} alt="Munshi App" className="w-48 h-48 drop-shadow-2xl" />
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
