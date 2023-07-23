using System;
using System.Collections.Generic;

namespace oscs
{
    [Serializable]
    public class Collection
    {
        private Dictionary<string, object> M_Collection;

        public Collection()
        {
            M_Collection = new Dictionary<string, object>();
        }

        public Collection(Dictionary<string, object> p1)
        {
            M_Collection = p1;
        }

        public Collection(oscs.Collection p1)
        {
            M_Collection = p1.M_Collection;
        }

        public int Count
        {
            get
            {
                int count = 0;
                foreach (KeyValuePair<string, object>  DictionaryEntry in M_Collection)
                {
                    count = count + 1;
                }
                return count;
            }
        }

        public object this[string index]
        {
            get { return M_Collection[index]; }
        }

        public System.Collections.IEnumerator GetEnumerator()
        {
            return M_Collection.GetEnumerator();
        }

        public void Add(string key, object item)
        {
            M_Collection.Add(key, item);
        }

        public void Remove(string index)
        {
            M_Collection.Remove(index);
        }
    }
}
