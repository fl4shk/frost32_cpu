#ifndef src__slash__symbol_table_classes_hpp
#define src__slash__symbol_table_classes_hpp

// src/symbol_table_classes.hpp

#include "misc_includes.hpp"

#include "scoped_table_base_class.hpp"


class Symbol
{
private:		// variables
	Ident __name;

	u64 __addr = 0;
	bool __found_as_label = false;


public:		// functions
	inline Symbol()
	{
	}
	inline Symbol(Ident s_name, u64 s_addr)
		: __name(s_name), __addr(s_addr), __found_as_label(false)
	{
	}
	inline Symbol(const Symbol& to_copy) = default;
	inline Symbol(Symbol&& to_move) = default;

	inline Symbol& operator = (const Symbol& to_copy) = default;
	inline Symbol& operator = (Symbol&& to_move) = default;

	gen_getter_and_setter_by_con_ref(name);
	gen_setter_by_rval_ref(name);

	gen_getter_and_setter_by_val(addr);
	gen_getter_and_setter_by_val(found_as_label);
};


class SymbolTable : public ScopedTableBase<Symbol>
{
public:		// functions
	SymbolTable();
	virtual ~SymbolTable();
};




#endif		// src__slash__symbol_table_classes_hpp
