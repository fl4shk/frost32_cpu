#ifndef scoped_table_base_class_hpp
#define scoped_table_base_class_hpp

#include "misc_includes.hpp"
#include "ident_table_classes.hpp"

template<typename Type>
class ScopedTableNode
{
public:		// variables
	IdentToPointerTable<Type> table;

	ScopedTableNode* parent;
	std::vector<ScopedTableNode*> children;


public:		// functions
	virtual ~ScopedTableNode()
	{
	}

	inline ScopedTableNode(ScopedTableNode* s_parent=nullptr)
		: parent(s_parent)
	{
	}

	inline void append_child(ScopedTableNode* to_append)
	{
		children.push_back(to_append);
	}

	std::vector<std::map<Ident, Type*>*> get_all_children_tables() const
		__attribute__((noinline))
	{
		std::vector<std::map<Ident, Type*>*> ret;

		__inner_func_get_all_children_tables(ret);

		return ret;
	}

protected:		// functions
	void __inner_func_get_all_children_tables
		(std::vector<std::map<Ident, Type*>*>& ret) const
		__attribute__((noinline))
	{
		// Find all the tables
		for (auto iter : children)
		{
			ret.push_back(&(iter->table.table()));
			iter->__inner_func_get_all_children_tables(ret);
		}
	}
	

};

// This is kind of like a stack
// 
// Symbols need to be kept around even after they go out of scope.
// This is useful for both optimization purposes (re-use old local variable
// space, for example) and also... to guarantee correct code generation,
// lol.
template<typename Type>
class ScopedTableBase
{
public:		// typedefs and constants
	//typedef IdentTable<Type> OneTable;
	//typedef IdentToPointerTable<Type> OneTable;

	static constexpr s64 builtin_scope_level = 0;
	static constexpr s64 not_found_level = builtin_scope_level - 1;

	typedef ScopedTableNode<Type> Node;

public:		// classes


protected:		// variables
	Node __tree;

	//Node* __curr_node = &__tree;
	//Node* __curr_node = nullptr;


	// The number of scopes that have been made - 1
	s64 __scope_num = -1;

	std::vector<Node*> __node_pool;
	std::vector<Type*> __data_pool;

	//std::map<Ident, Node*> __ident_to_global_map;

	//std::map<Ident, Node*> __ident_to_func_node_map;

public:		// functions
	inline ScopedTableBase()
	{
		//__curr_node = &__tree;
		auto some_curr_node = &__tree;
		mkscope(some_curr_node);
	}
	virtual ~ScopedTableBase()
	{
		for (size_t i=0; i<__node_pool.size(); ++i)
		{
			delete __node_pool.at(i);
		}

		for (size_t i=0; i<__data_pool.size(); ++i)
		{
			delete __data_pool.at(i);
		}
	}

	void mkscope(Node*& some_curr_node) __attribute__((noinline))
	{
		//if (__curr_node == nullptr)
		//{
		//	printerr("ScopedTableBase::mkscope():  Eek!\n");
		//	exit(1);
		//}

		++__scope_num;

		if (scope_num() < 0)
		{
			printerr("ScopedTableBase::mkscope():  ",
				"Far, FAR too many scopes!\n");
			exit(1);
		}

		__node_pool.push_back(new Node(some_curr_node));

		some_curr_node->append_child(__node_pool.back());
		auto old_curr_node = some_curr_node;
		some_curr_node = some_curr_node->children.back();
		some_curr_node->parent = old_curr_node;

		//some_curr_node->table = scope_num();
	}
	void rmscope(Node*& some_curr_node) __attribute__((noinline))
	{
		if (some_curr_node != &__tree)
		{
			some_curr_node = some_curr_node->parent;
		}
		//if (some_curr_node->global_name != nullptr)
		//{
		//	some_curr_node = some_curr_node->parent;
		//}
		//if (!curr_node_is_subtree())
		//{
		//	some_curr_node = some_curr_node->parent;
		//}
		else
		{
			printerr("ScopedTableBase::rmscope():  Eek!\n");
			exit(1);
		}
	}

	inline void insert_or_assign(Node* some_curr_node,
		const Type& to_insert_or_assign)
	{
		__data_pool.push_back(new Type(to_insert_or_assign));
		some_curr_node->table.insert_or_assign(__data_pool.back());
	}
	inline void insert_or_assign(Node* some_curr_node,
		Type&& to_insert_or_assign)
	{
		__data_pool.push_back(new Type(std::move(to_insert_or_assign)));
		some_curr_node->table.insert_or_assign(__data_pool.back());
	}


	Type* find(Node* some_curr_node, Ident some_name) 
		__attribute__((noinline))
	{
		//for (s64 i=scope_lev(); i>=builtin_scope_level; --i)
		for (auto p=some_curr_node; p!=&__tree; p=p->parent)
		{
			//if (table().at(i).contains(some_name))
			//{
			//	return &table().at(i).at(some_name);
			//}
			if (p->table.contains(some_name))
			{
				return p->table.at(some_name);
			}
		}

		return nullptr;
	}


	inline Type* find_func_arg(Node* some_func_node, Ident some_name)
	{
		//auto func_node = __ident_to_func_node_map.at(some_func_name);

		if (some_func_node->children.front()->table.contains(some_name))
		{
			return some_func_node->children.front()->table.at(some_name);
		}

		return nullptr;
	}

	inline Type* find_in_this_blklev(Node* some_curr_node, Ident some_name)
	{
		//if (table.at(scope_lev()).back().contains(some_name))
		//{
		//	return &table.at(scope_lev()).back().at(some_name);
		//}

		if (some_curr_node->table.contains(some_name))
		{
			return some_curr_node->table.at(some_name);
		}

		return nullptr;
	}

	inline Type* find_or_insert(Node* some_curr_node, Ident some_name)
	{
		{
			auto search = find(some_curr_node, some_name);

			if (search != nullptr)
			{
				return search;
			}
		}

		Type to_insert;
		to_insert.set_name(some_name);
		insert_or_assign(some_curr_node, std::move(to_insert));

		return find(some_curr_node, some_name);
	}

	gen_getter_by_con_ref(tree);
	gen_getter_by_ref(tree);

	gen_getter_by_val(scope_num);
	//gen_getter_by_val(scope_lev);
};


#endif		// scoped_table_base_class_hpp
