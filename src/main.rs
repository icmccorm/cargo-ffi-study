use std::env;
use syn::visit::{self, Visit};
use syn::{File, ItemFn};
use std::fs::read_to_string;

fn read_file_string(filepath: &str) -> Result<String, Box<dyn std::error::Error>> {
    let data = read_to_string(filepath)?;
    Ok(data)
}


struct FnVisitor;

impl<'ast> Visit<'ast> for FnVisitor {
    fn visit_item_fn(&mut self, node: &'ast ItemFn) {
        println!("Function with name={}", node.sig.ident);

        // Delegate to the default impl to visit any nested functions.
        visit::visit_item_fn(self, node);
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    for arg in args {
        match read_file_string(&arg) {
            Ok(code) => {
                let syntax_tree: File = syn::parse_str(&code).unwrap();
                FnVisitor.visit_file(&syntax_tree);
            }
            Err(_) => {
                println!("Error: unable to parse file.")
            }
        }
    }
}
