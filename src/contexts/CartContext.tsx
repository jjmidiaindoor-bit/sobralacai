import React, { createContext, useContext, useState, useCallback, useEffect } from "react";
import { CartItem, Product } from "@/lib/types";

interface CartContextType {
  items: CartItem[];
  addItem: (product: Product) => void;
  removeItem: (productId: string) => void;
  updateQuantity: (productId: string, quantity: number) => void;
  clearCart: () => void;
  total: number;
  itemCount: number;
  justAdded: string | null;
  currentLojaId: string | null;
  setLojaContext: (lojaId: string) => void;
}

const CartContext = createContext<CartContextType | undefined>(undefined);

const CART_STORAGE_KEY = "acai-cart";
const LOJA_STORAGE_KEY = "acai-loja-id";

export function CartProvider({ children }: { children: React.ReactNode }) {
  const [currentLojaId, setCurrentLojaId] = useState<string | null>(() => {
    return localStorage.getItem(LOJA_STORAGE_KEY);
  });
  
  const [items, setItems] = useState<CartItem[]>(() => {
    const saved = localStorage.getItem(CART_STORAGE_KEY);
    if (saved) {
      try {
        const parsed = JSON.parse(saved);
        // Só restaura se for da mesma loja
        if (parsed.lojaId === currentLojaId) {
          return parsed.items || [];
        }
      } catch {}
    }
    return [];
  });
  
  const [justAdded, setJustAdded] = useState<string | null>(null);

  // Salvar carrinho no localStorage sempre que mudar
  useEffect(() => {
    localStorage.setItem(CART_STORAGE_KEY, JSON.stringify({
      lojaId: currentLojaId,
      items
    }));
  }, [items, currentLojaId]);

  const setLojaContext = useCallback((lojaId: string) => {
    const prevLojaId = currentLojaId;
    setCurrentLojaId(lojaId);
    localStorage.setItem(LOJA_STORAGE_KEY, lojaId);
    
    // Limpa o carrinho se mudou de loja
    if (prevLojaId && prevLojaId !== lojaId) {
      setItems([]);
    }
  }, [currentLojaId]);

  const addItem = useCallback((product: Product) => {
    setItems((prev) => {
      const existing = prev.find((i) => i.product.id === product.id);
      if (existing) {
        return prev.map((i) =>
          i.product.id === product.id ? { ...i, quantity: i.quantity + 1 } : i
        );
      }
      return [...prev, { product, quantity: 1 }];
    });
    setJustAdded(product.id);
    setTimeout(() => setJustAdded(null), 600);
  }, []);

  const removeItem = useCallback((productId: string) => {
    setItems((prev) => prev.filter((i) => i.product.id !== productId));
  }, []);

  const updateQuantity = useCallback((productId: string, quantity: number) => {
    if (quantity <= 0) {
      setItems((prev) => prev.filter((i) => i.product.id !== productId));
      return;
    }
    setItems((prev) =>
      prev.map((i) =>
        i.product.id === productId ? { ...i, quantity } : i
      )
    );
  }, []);

  const clearCart = useCallback(() => setItems([]), []);

  const total = items.reduce((sum, i) => sum + i.product.preco * i.quantity, 0);
  const itemCount = items.reduce((sum, i) => sum + i.quantity, 0);

  return (
    <CartContext.Provider
      value={{ items, addItem, removeItem, updateQuantity, clearCart, total, itemCount, justAdded, currentLojaId, setLojaContext }}
    >
      {children}
    </CartContext.Provider>
  );
}

export function useCart() {
  const context = useContext(CartContext);
  if (!context) throw new Error("useCart must be used within CartProvider");
  return context;
}
