import { supabase } from "@/integrations/supabase/client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

// Função auxiliar para obter o loja_id do localStorage
function getLojaId(): string | null {
  const lojaData = localStorage.getItem("admin_loja");
  if (lojaData) {
    const loja = JSON.parse(lojaData);
    return loja.id;
  }
  return null;
}

// Categories
export function useCategories() {
  return useQuery({
    queryKey: ["categorias"],
    queryFn: async () => {
      const lojaId = getLojaId();
      const { data, error } = await supabase
        .from("categorias")
        .select("*")
        .eq("loja_id", lojaId!)
        .order("nome");
      if (error) return [];
      return data || [];
    },
  });
}

export function useSaveCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({ id, nome }: { id?: string; nome: string }) => {
      const lojaId = getLojaId();
      const payload = { nome, loja_id: lojaId };
      if (id) {
        const { error } = await supabase.from("categorias").update(payload).eq("id", id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from("categorias").insert(payload);
        if (error) throw error;
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["categorias"] }),
  });
}

export function useDeleteCategory() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from("categorias").delete().eq("id", id);
      if (error) throw error;
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["categorias"] }),
  });
}

// Products
export function useProducts() {
  return useQuery({
    queryKey: ["produtos"],
    queryFn: async () => {
      const lojaId = getLojaId();
      const { data, error } = await supabase
        .from("produtos")
        .select("*, categorias(nome)")
        .eq("loja_id", lojaId!)
        .order("nome");
      if (error) return [];
      return data || [];
    },
  });
}

export function useSaveProduct() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({
      id,
      nome,
      descricao,
      preco,
      foto_url,
      categoria_id,
    }: {
      id?: string;
      nome: string;
      descricao?: string;
      preco: number;
      foto_url?: string;
      categoria_id?: string;
    }) => {
      const lojaId = getLojaId();
      const payload = { nome, descricao, preco, foto_url, categoria_id, loja_id: lojaId };
      if (id) {
        const { error } = await supabase.from("produtos").update(payload).eq("id", id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from("produtos").insert(payload);
        if (error) throw error;
      }
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["produtos"] }),
  });
}

export function useDeleteProduct() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async (id: string) => {
      const { error } = await supabase.from("produtos").delete().eq("id", id);
      if (error) throw error;
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["produtos"] }),
  });
}

// Orders
export function useOrders() {
  return useQuery({
    queryKey: ["pedidos"],
    queryFn: async () => {
      const lojaId = getLojaId();
      const { data, error } = await supabase
        .from("pedidos")
        .select("*")
        .eq("loja_id", lojaId!)
        .order("created_at", { ascending: false });
      if (error) return [];
      return data || [];
    },
  });
}

export function useCreateOrder() {
  return useMutation({
    mutationFn: async (order: {
      nome_cliente: string;
      telefone: string;
      endereco?: string;
      observacao?: string;
      detalhes_pedido: string;
      total: number;
    }) => {
      const lojaId = getLojaId();
      const orderWithLoja = { ...order, loja_id: lojaId };
      const { error } = await supabase.from("pedidos").insert(orderWithLoja);
      if (error) throw error;
    },
  });
}

// Settings
export function useSettings() {
  return useQuery({
    queryKey: ["configuracoes"],
    queryFn: async () => {
      const lojaId = getLojaId();
      const { data, error } = await supabase
        .from("configuracoes")
        .select("*")
        .eq("loja_id", lojaId!)
        .limit(1)
        .single();
      if (error) return null;
      return data;
    },
  });
}

// Settings para loja específica (pública)
export function useSettingsByLojaId(lojaId: string | undefined) {
  return useQuery({
    queryKey: ["configuracoes", lojaId],
    queryFn: async () => {
      if (!lojaId) return null;
      const { data, error } = await supabase
        .from("configuracoes")
        .select("*")
        .eq("loja_id", lojaId)
        .limit(1)
        .single();
      if (error) return null;
      return data;
    },
    enabled: !!lojaId,
  });
}

// Dados da loja
export function useLojaById(lojaId: string | undefined) {
  return useQuery({
    queryKey: ["loja", lojaId],
    queryFn: async () => {
      if (!lojaId) return null;
      const { data, error } = await supabase
        .from("lojas")
        .select("*")
        .eq("id", lojaId)
        .single();
      if (error) return null;
      return data;
    },
    enabled: !!lojaId,
  });
}

// Produtos de uma loja específica
export function useProductsByLojaId(lojaId: string | undefined) {
  return useQuery({
    queryKey: ["produtos", lojaId],
    queryFn: async () => {
      if (!lojaId) return [];
      const { data, error } = await supabase
        .from("produtos")
        .select("*, categorias(nome)")
        .eq("loja_id", lojaId)
        .order("nome");
      if (error) return [];
      return data || [];
    },
    enabled: !!lojaId,
  });
}

// Categorias de uma loja específica
export function useCategoriesByLojaId(lojaId: string | undefined) {
  return useQuery({
    queryKey: ["categorias", lojaId],
    queryFn: async () => {
      if (!lojaId) return [];
      const { data, error } = await supabase
        .from("categorias")
        .select("*")
        .eq("loja_id", lojaId)
        .order("nome");
      if (error) return [];
      return data || [];
    },
    enabled: !!lojaId,
  });
}

export function useUpdateSettings() {
  const qc = useQueryClient();
  return useMutation({
    mutationFn: async ({
      id,
      ...values
    }: {
      id: string;
      nome_loja?: string;
      telefone_whatsapp?: string;
      endereco?: string;
      logo_url?: string;
      banner_url?: string;
      slogan?: string;
    }) => {
      const lojaId = getLojaId();
      const { error } = await supabase.from("configuracoes").update({ ...values, loja_id: lojaId }).eq("id", id);
      if (error) throw error;
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["configuracoes"] }),
  });
}
