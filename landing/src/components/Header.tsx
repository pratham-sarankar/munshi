import { Button } from "./ui/button";
import { Menu, Github } from "lucide-react";
import logo from "@/assets/logo.png";

export function Header() {
  return (
    <header className="sticky top-0 z-50 bg-white/95 backdrop-blur-md border-b border-border px-6 py-4 shadow-sm">
      <div className="mx-auto max-w-7xl flex items-center justify-between">
        <div className="flex items-center gap-12">
          <div className="flex items-center gap-2">
            <img src={logo} alt="Munshi Logo" className="w-8 h-8" />
            <span className="text-xl text-foreground">Munshi</span>
          </div>
          
          <nav className="hidden md:flex items-center gap-8">
            <a href="#features" className="text-secondary hover:text-foreground transition-colors">
              Features
            </a>
            <a href="#how-it-works" className="text-secondary hover:text-foreground transition-colors">
              How It Works
            </a>
            <a href="#screenshots" className="text-secondary hover:text-foreground transition-colors">
              Screenshots
            </a>
            <a href="#faq" className="text-secondary hover:text-foreground transition-colors">
              FAQ
            </a>
          </nav>
        </div>
        
        <div className="flex items-center gap-4">
          <a 
            href="https://github.com/pratham-sarankar/munshi" 
            target="_blank" 
            rel="noopener noreferrer"
            className="hidden md:inline-flex"
          >
            <Button variant="ghost" className="gap-2">
              <Github className="h-5 w-5" />
              GitHub
            </Button>
          </a>
          <Button className="bg-primary hover:bg-primary/90 text-primary-foreground">
            Download
          </Button>
          <Button variant="ghost" size="icon" className="md:hidden">
            <Menu className="h-5 w-5" />
          </Button>
        </div>
      </div>
    </header>
  );
}
