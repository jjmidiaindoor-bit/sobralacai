import { Outlet, Link, useNavigate, useLocation } from "react-router-dom";
import { Button } from "@/components/ui/button";
import { useAuth } from "@/contexts/AuthContext";
import { LogOut, Store } from "lucide-react";

export default function SuperAdminLayout() {
  const { signOut } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();

  const handleSignOut = async () => {
    await signOut();
    navigate("/super-admin/login");
  };

  const isActive = (path: string) => location.pathname === path;

  return (
    <div className="min-h-screen bg-background">
      <header className="border-b-2 border-border bg-card">
        <div className="container mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <Store className="h-6 w-6 text-accent" />
            <div>
              <h1 className="font-heading text-xl uppercase">Super Admin</h1>
              <p className="text-xs text-muted-foreground">Painel de Controle</p>
            </div>
          </div>
          <div className="flex items-center gap-4">
            <nav className="flex gap-2">
              <Link to="/super-admin/lojas">
                <Button variant={isActive("/super-admin/lojas") ? "default" : "outline"} size="sm">LOJAS</Button>
              </Link>
            </nav>
            <Button variant="outline" size="sm" onClick={handleSignOut}>
              <LogOut className="h-4 w-4 mr-2" /> SAIR
            </Button>
          </div>
        </div>
      </header>
      <main className="container mx-auto px-4 py-8"><Outlet /></main>
    </div>
  );
}
