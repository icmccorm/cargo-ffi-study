use std::env;
use std::fs::read_to_string;
use syn::spanned::Spanned;
use syn::token::{Colon, Default};
use syn::visit::{self, Visit};
use syn::Type;
use syn::{ExprCall, ExprMethodCall, File, ForeignItemFn, PathSegment, ReturnType};
use walkdir::WalkDir;

fn read_file_string(filepath: &str) -> Result<String, Box<dyn std::error::Error>> {
    let data = read_to_string(filepath)?;
    Ok(data)
}

fn string_of_type(t: &Type) -> String {
    match t {
        Type::Path(tp) => {
            let segment_names: Vec<String> = tp
                .path
                .segments
                .iter()
                .map(|ps| ps.ident.to_string())
                .collect();
            segment_names.join("::")
        }
        Type::Ptr(inner) => String::from("*") + &string_of_type(&*inner.elem),
        Type::Reference(inner) => String::from("&") + &string_of_type(&*inner.elem),
        Type::Slice(_) => String::from("Slice"),
        Type::TraitObject(_) => String::from("TraitObject"),
        Type::Tuple(_) => String::from("Tuple"),
        Type::Verbatim(_) => String::from("Verbatim"),
        _ => String::from("N/A"),
    }
}

struct ForeignDecl {
    id: usize,
    name: String,
}
struct FnVisitor<'a> {
    id_counter: usize,
    decls: &'a mut Vec<ForeignDecl>,
}

struct FnArg {
    function_id: usize,
    reference_type: bool,
}

impl<'ast> Visit<'ast> for FnVisitor<'_> {
    fn visit_foreign_item_fn(&mut self, node: &'ast ForeignItemFn) {
        let repr = ForeignDecl {
            id: self.id_counter,
            name: node.sig.ident.to_string()
        };
        self.id_counter += 1;
        self.decls.push(repr);
        
        visit::visit_foreign_item_fn(self, node);
    }
}

fn main() {
    let args: Vec<String> = env::args().collect();
    match args.get(1) {
        Some(arg) => {
            let mut visitor = FnVisitor {
                id_counter: 0,
                decls: & mut Vec::<ForeignDecl>::new(),
            };
            for entry in WalkDir::new(arg)
                .follow_links(true)
                .into_iter()
                .filter_map(|e| e.ok())
            {
                let f_name = entry.file_name().to_string_lossy();
                if f_name.ends_with(".rs") {
                    match entry.path().to_str() {
                        Some(resolved_path) => match read_file_string(&resolved_path) {
                            Ok(code) => {
                                let syntax_tree: File = syn::parse_str(&code).unwrap();
                                visitor.visit_file(&syntax_tree);
                            }
                            Err(_) => {
                            }
                        },
                        None => {}
                    }
                }
            }
            if(visitor.decls.len() > 0) {
                std::process::exit(0);
            }else{
                std::process::exit(1);
            }
        }
        None => {
            panic!("Usage: findffi [dir]");
        }
    }
}
