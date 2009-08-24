{-# LANGUAGE ForeignFunctionInterface #-}
-- {-# LANGUAGE TypeSynonymInstances #-}
module RubyMap where
#include "rshim.h"
#include <ruby.h>

-- import Data.Array.CArray as CArray
import Data.Word
import Foreign.Ptr
import Foreign.C.Types	
import Foreign.C.String

{# context lib="rshim" #}


{# enum RubyType {} deriving (Eq) #} -- maybe Ord?


type Value = CULong


-- -- FIXME jhc doesn't like importing floating point numbers, for some reason.

foreign import ccall unsafe "ruby.h rb_str_to_str" rb_str_to_str :: Value -> CString
foreign import ccall unsafe "ruby.h rb_ary_new2" rb_ary_new :: Int -> IO Value
foreign import ccall unsafe "ruby.h rb_ary_store" rb_ary_store :: Value -> Int -> Value -> IO ()
foreign import ccall unsafe "ruby.h rb_float_new" rb_float_new :: Double -> Value

-- -- we're being a bit filthy here - the interface is all macros, so we're digging in to find what it actually is
foreign import ccall unsafe "rshim.h rtype" rtype :: Value -> Int
foreign import ccall unsafe "rshim.h int2fix" int2fix :: Int -> Value
foreign import ccall unsafe "rshim.h fix2int" fix2int ::  Value -> Int

foreign import ccall unsafe "rshim.h num2dbl" num2dbl :: Value -> Double  -- technically CDoubles, but jhc promises they're the same



-- all values in here need to be allocated and tracked by ruby.
-- ByteStrings... hm. Probably better to keep them as C-side ruby strings.
-- better come back and expand this later
data RValue = T_NIL  
--            | T_OBJECT 
--             | T_CLASS      
--             | T_MODULE     
            | T_FLOAT Double
            | T_STRING CString
--            | T_REGEXP     
              -- the array needs to be managed by ruby
--            | T_ARRAY (CArray Word RValue)
            | T_FIXNUM Int --fixme, probably
              -- the hash needs to be managed by ruby
            | T_HASH  Int -- definitely FIXME - native ruby hashes, or going to translitrate?
--            | T_STRUCT     
            | T_BIGNUM Integer    
--            | T_FILE       
            | T_TRUE  
            | T_FALSE      
--            | T_DATA       
            | T_SYMBOL Word -- interned string
--              deriving Show


-- qnil = 4
-- qfalse = 0
-- qtrue = 2

toRuby :: RValue -> Value
toRuby r = case r of
--           T_NIL -> qnil
           T_FLOAT d -> rb_float_new d
                        -- need to take the address of the cstr, just cast it to a value
           T_STRING cstr -> undefined
           T_FIXNUM i -> int2fix i
           --T_TRUE ->  RT_TRUE
           --T_FALSE -> RT_FALSE
           x -> error ("sorry, haven't implemented that yet.")

fromRuby :: Value -> RValue
fromRuby v = case toEnum $ rtype v of
               RT_NIL -> T_NIL
               RT_FIXNUM -> T_FIXNUM $ fix2int v
               RT_STRING -> undefined
               RT_FLOAT ->  T_FLOAT $ num2dbl v