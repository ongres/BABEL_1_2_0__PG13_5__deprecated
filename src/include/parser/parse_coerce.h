/*-------------------------------------------------------------------------
 *
 * parse_coerce.h
 *	Routines for type coercion.
 *
 *
 * Portions Copyright (c) 1996-2020, PostgreSQL Global Development Group
 * Portions Copyright (c) 1994, Regents of the University of California
 *
 * src/include/parser/parse_coerce.h
 *
 *-------------------------------------------------------------------------
 */
#ifndef PARSE_COERCE_H
#define PARSE_COERCE_H

#include "parser/parse_node.h"


/* Type categories (see TYPCATEGORY_xxx symbols in catalog/pg_type.h) */
typedef char TYPCATEGORY;

/* Result codes for find_coercion_pathway */
typedef enum CoercionPathType
{
	COERCION_PATH_NONE,			/* failed to find any coercion pathway */
	COERCION_PATH_FUNC,			/* apply the specified coercion function */
	COERCION_PATH_RELABELTYPE,	/* binary-compatible cast, no function */
	COERCION_PATH_ARRAYCOERCE,	/* need an ArrayCoerceExpr node */
	COERCION_PATH_COERCEVIAIO	/* need a CoerceViaIO node */
} CoercionPathType;


extern bool IsBinaryCoercible(Oid srctype, Oid targettype);
extern bool IsPreferredType(TYPCATEGORY category, Oid type);
extern TYPCATEGORY TypeCategory(Oid type);

extern Node *coerce_to_target_type(ParseState *pstate,
								   Node *expr, Oid exprtype,
								   Oid targettype, int32 targettypmod,
								   CoercionContext ccontext,
								   CoercionForm cformat,
								   int location);
extern bool can_coerce_type(int nargs, const Oid *input_typeids, const Oid *target_typeids,
							CoercionContext ccontext);
extern Node *coerce_type(ParseState *pstate, Node *node,
						 Oid inputTypeId, Oid targetTypeId, int32 targetTypeMod,
						 CoercionContext ccontext, CoercionForm cformat, int location);
extern Node *coerce_to_domain(Node *arg, Oid baseTypeId, int32 baseTypeMod,
							  Oid typeId,
							  CoercionContext ccontext, CoercionForm cformat, int location,
							  bool hideInputCoercion);

extern Node *coerce_to_boolean(ParseState *pstate, Node *node,
							   const char *constructName);
extern Node *coerce_to_specific_type(ParseState *pstate, Node *node,
									 Oid targetTypeId,
									 const char *constructName);

extern Node *coerce_to_specific_type_typmod(ParseState *pstate, Node *node,
											Oid targetTypeId, int32 targetTypmod,
											const char *constructName);

extern int	parser_coercion_errposition(ParseState *pstate,
										int coerce_location,
										Node *input_expr);

extern Oid	select_common_type(ParseState *pstate, List *exprs,
							   const char *context, Node **which_expr);
extern Node *coerce_to_common_type(ParseState *pstate, Node *node,
								   Oid targetTypeId,
								   const char *context);

extern bool check_generic_type_consistency(const Oid *actual_arg_types,
										   const Oid *declared_arg_types,
										   int nargs);
extern Oid	enforce_generic_type_consistency(const Oid *actual_arg_types,
											 Oid *declared_arg_types,
											 int nargs,
											 Oid rettype,
											 bool allow_poly);

extern char *check_valid_polymorphic_signature(Oid ret_type,
											   const Oid *declared_arg_types,
											   int nargs);
extern char *check_valid_internal_signature(Oid ret_type,
											const Oid *declared_arg_types,
											int nargs);

extern CoercionPathType find_coercion_pathway(Oid targetTypeId,
											  Oid sourceTypeId,
											  CoercionContext ccontext,
											  Oid *funcid);
extern CoercionPathType find_typmod_coercion_function(Oid typeId,
													  Oid *funcid);

/*
 * Hook interface to check TSQL has implicit coercion path from sourceTypeId to targetTypeId
 */
typedef CoercionPathType (*find_coercion_pathway_hook_type) (Oid sourceTypeId,
									Oid targetTypeId,
									CoercionContext ccontext,
									Oid *funcid);

/*
 * Hook interface to check TSQL datatype precedence
 * Return true if typeId1 precedes typeId2
 */
typedef bool (*determine_datatype_precedence_hook_type) (Oid typeId1, Oid typeId2);

/*
 * T-SQL has different rules for string literal datatype coercions
 */
typedef Node *(*coerce_string_literal_hook_type) (ParseCallbackState *pcbstate,
												  Oid targetTypeId,
												  int32 targetTypeMod,
												  int32 baseTypeMod,
												  Const *newcon,
												  char *value,
												  CoercionContext ccontext,
												  CoercionForm cformat,
												  int location);

/*
 * T-SQL may forbid casting from string literal to certain datatypes (i.e. binary, varbinary)
 */
typedef void (*validate_implicit_conversion_from_string_literal_hook_type) (Const *newcon, const char *value);

#endif							/* PARSE_COERCE_H */