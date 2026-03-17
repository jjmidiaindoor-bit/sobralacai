import { supabase } from "@/integrations/supabase/client";
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

const SCHEMA = import.meta.env.VITE_SUPABASE_SCHEMA || 'sobralacai';

// Categories
export function useCategories() {
  return useQuery({
    queryKey: ["categorias"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from(`${SCHEMA}.categorias`)
        .select("*")
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
      const payload = { nome, loja_id: null };
      if (id) {
        const { error } = await supabase.from(`${SCHEMA}.categorias`).update(payload).eq("id", id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from(`${SCHEMA}.categorias`).insert(payload);
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
      const { error } = await supabase.from(`${SCHEMA}.categorias`).delete().eq("id", id);
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
      const { data, error } = await supabase
        .from(`${SCHEMA}.produtos`)
        .select("*, categorias(nome)")
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
      const payload = { nome, descricao, preco, foto_url, categoria_id, loja_id: null };
      if (id) {
        const { error } = await supabase.from(`${SCHEMA}.produtos`).update(payload).eq("id", id);
        if (error) throw error;
      } else {
        const { error } = await supabase.from(`${SCHEMA}.produtos`).insert(payload);
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
      const { error } = await supabase.from(`${SCHEMA}.produtos`).delete().eq("id", id);
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
      const { data, error } = await supabase
        .from(`${SCHEMA}.pedidos`)
        .select("*")
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
      const { error } = await supabase.from(`${SCHEMA}.pedidos`).insert(order);
      if (error) throw error;
    },
  });
}

// Settings
export function useSettings() {
  return useQuery({
    queryKey: ["configuracoes"],
    queryFn: async () => {
      const { data, error } = await supabase
        .from(`${SCHEMA}.configuracoes`)
        .select("*")
        .limit(1)
        .single();
      if (error) return null;
      return data;
    },
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
      const { error } = await supabase.from(`${SCHEMA}.configuracoes`).update(values).eq("id", id);
      if (error) throw error;
    },
    onSuccess: () => qc.invalidateQueries({ queryKey: ["configuracoes"] }),
  });
}
