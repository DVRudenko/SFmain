public class PD_XPath
{
    // The different types of predicate expressions.
    private static final Integer PRED_TYPE_INVALID    = 0;
    private static final Integer PRED_TYPE_NONE       = 1;
    private static final Integer PRED_TYPE_INDEX      = 2;
    private static final Integer PRED_TYPE_HAS_ATTR   = 3;
    private static final Integer PRED_TYPE_ATTR_VALUE = 4;

    // Regexes for parsing the parts of a pathnode.
    private static final String rxSlashes   = '\\/{0,2}';         // Starts with zero, 1, or 2 slashes.
    private static final String rxNodeTest  = '[^\\s^\\[^\\/]+';  // Nonblank chars before the next [ or /
    private static final String rxPredicate = '(\\[[^\\]]+\\])?'; // [anything]

    public Dom.Document doc {get; private set; }
    public Dom.XmlNode root {get; private set; }

    private PathNode[] compiledPath;

    private static Map<String, PathNode[]> cache = new Map<String, PathNode[]>();

    public PD_XPath (String xml) {
        this.doc = new Dom.Document();
        this.doc.load(xml);
        this.root = this.doc.getRootElement();
    }

    public PD_XPath (Dom.Document doc) {
        this.doc = doc;
        this.root = this.doc.getRootElement();
    }

    public String getText (String path) {
        return this.getText(this.root, path);
    }

    public String getText (Dom.XmlNode startNode, String path) {
        Dom.XmlNode[] nodes = this.find(startNode, path);
        String ret = null;

        if (nodes.size() > 0) {
            ret = nodes[0].getText();
        }

        return ret;
    }

    public String getText (String delimiter, String path) {
        return this.getText (this.root, delimiter, path);
    }

    public String getText (Dom.XmlNode startNode, String delimiter, String path) {
        Dom.XmlNode[] nodes = this.find(startNode, path);
        String[] strings = new String[0];
        String ret = null;

        for (Dom.XmlNode node : nodes) {
            strings.add(node.getText());
        }

        ret = String.join(strings, delimiter);

        return ret;
    }

    public String[] getTextList (String path) {
        return this.getTextList(this.root, path);
    }

    public String[] getTextList (Dom.XmlNode startNode, String path) {
        Dom.XmlNode[] nodes = this.find(startNode, path);
        String[] ret = new String[0];

        for (Dom.XmlNode node : nodes) {
            ret.add(node.getText());
        }

        return ret;
    }

    public Dom.XmlNode findFirst (String path) {
        return this.findFirst(this.root, path);
    }

    public Dom.XmlNode findFirst (Dom.XmlNode startNode, String path) {
        Dom.XmlNode[] nodes = this.find(startNode, path);

        Dom.XmlNode ret = null;
        if (nodes.size() > 0) {
            ret = nodes[0];
        }

        return ret;
    }

    public Dom.XmlNode[] find (String path) {
        return this.find(this.root, path);
    }

    public Dom.XmlNode[] find (Dom.XmlNode startNode, String path) {
        Boolean childrenOnly = true;

        PathNode[] compiledPath = new PathNode[0];

        Dom.XmlNode[] currNodes = new Dom.XmlNode[0];
        Dom.XmlNode[] newNodes  = new Dom.XmlNode[0];


        // Sanity checks.
        if (startNode == null || String.isEmpty(path)) {
            return currNodes;
        }


        // Determine which node the path starts from. An PD_XPath that starts with "/" or "//" is an
        // absolute path which starts from the doc's root, else the search starts from the specified node.
        if (path.startsWith('/')) {
            Dom.XmlNode root = this.doc.getRootElement();
            if (root == null) {
                return currNodes;
            }
            else {
                currNodes.add(root);
            }
        }
        else {
            currNodes.add(startNode);
        }


        // See if the PD_XPath has already been compiled. If not, compile it now and add it to the cache.
        if (this.isPathCached(path)) {
            compiledPath = PD_XPath.cache.get(path);
        }
        else {
            compiledPath = this.compile(path);
            PD_XPath.cache.put(path, compiledPath);
        }


        // Given the compiled path, iterate its List of nodes and process them against the actual DOM tree.
        Boolean is1stPathNode = true;
        for (PathNode compiledPathNode : compiledPath) {
            // For each pathnode we process, we end up with a list of nodes (currNodes) that are candidates
            // for fulfilling the PD_XPath.
            newNodes.clear();
            for (Dom.XmlNode node : currNodes) {
                if (is1stPathNode && compiledPathNode.numSlashes == 1) {
                    // We're at the first pathnode in the path, and it started with a "/".
                    // So this pathnode is referring to the root element.
                    newNodes.addAll(this.processNode(node, compiledPathNode));
                }
                else if (compiledPathNode.nodeTest.isDot()) {
                    newNodes.add(node);
                }
                else if (compiledPathNode.nodeTest.isDoubleDot()) {
                    if (node.getParent() != null) {
                        newNodes.add(node.getParent());
                    }
                }
                else if (compiledPathNode.numSlashes <= 1) {
                    // We're at the first pathnode and it did not start with a slash, or we're
                    // past the first pathnode. Either way this pathnode is referring to this
                    // element's children.
                    newNodes.addAll(this.processChildren(node, compiledPathNode));
                }
                else { // Starts with //
                    System.debug('PD_XPath - // is not supported');
                    break;
                }
            }

            // In some cases we can end up with duplicate nodes in our candidate list. So we de-dup the
            // list here. (NOTE: You might think, since we want to eliminate duplicates from the list
            // we should be storing them in a Set instead of a List. However, a Set is un-ordered, and
            // we want to keep the results in the same order that they appeared in the XML. So we'll
            // store them in a List to preserve their order and just de-dup them as necessary.)
            Set<Dom.XmlNode> dedup = new Set<Dom.XmlNode>();
            for (Integer ix = newNodes.size() - 1; ix >= 0; ix--) {
                if (dedup.contains(newNodes[ix])) {
                    newNodes.remove(ix);
                }
                else {
                    dedup.add(newNodes[ix]);
                }
            }

            // Now we have a new list of nodes representing our candidates after analyzing this
            // node in the PD_XPath. We'll analyze the next node in the path against this new list.
            currNodes = newNodes.clone();

            is1stPathNode = false;
        }

        return currNodes;
    }

    public Boolean isPathCached (String path) {
        return PD_XPath.cache.containsKey(path);
    }

    private PathNode[] compile (String path) {
        PathNode[] compiled  = new PathNode[0];

        // Parse each node in the path & fill up our list of candidate nodes.
        Pattern pPathnodes = Pattern.compile(PD_XPath.rxSlashes + PD_XPath.rxNodeTest + PD_XPath.rxPredicate);
        Matcher mPathnodes = pPathnodes.matcher(path);

        while (mPathnodes.find()) {
            String pathNodeSrc = mPathnodes.group();

            PathNode pathnode = new PathNode(pathNodeSrc);
            compiled.add(pathnode);
        }

        return compiled;
    }

    private Dom.XmlNode[] processNode(Dom.XmlNode node, PathNode pathNode) {
        Dom.XmlNode[] tempNodes = new Dom.XmlNode[0];
        Dom.XmlNode[] retNodes  = new Dom.XmlNode[0];

        // See if this node matches the namespace (if specified) & tagname.
        if (this.matchesNodeTest(node, pathNode.nodeTest)) {
            tempNodes.add(node);
        }

        // Now filter it by the predicate, if any. I.e. if it doesn't pass the predicate test, remove
        // it from the candidate array.
        retNodes.addAll(this.filterByPredicate(tempNodes, pathNode.predicate));

        return retNodes;
    }

    private Dom.XmlNode[] processChildren(Dom.XmlNode node, PathNode pathNode) {
        Dom.XmlNode[] tempNodes = new Dom.XmlNode[0];
        Dom.XmlNode[] retNodes  = new Dom.XmlNode[0];

        // Get all the immediate children that match the namespace (if specified) & tagname.
        for (Dom.XmlNode child : node.getChildElements()) {
            if (this.matchesNodeTest(child, pathNode.nodeTest)) {
                tempNodes.add(child);
            }
        }

        // Now, for each node that matches the tagname, filter it by the predicate, if any.
        retNodes.addAll(this.filterByPredicate(tempNodes, pathNode.predicate));

        return retNodes;
    }

    private Boolean matchesNodeTest(Dom.XmlNode node, NodeTest nodeTest) {
        if (node.getNodeType() != Dom.XmlNodeType.ELEMENT) {
            return false;
        }

        if (nodeTest.isDot()) {
            return true;
        }

        // If a namespace was specified in the PD_XPath, check it against this node's tag.
        if (!String.isEmpty(nodeTest.ns)) {
            if (String.isEmpty(node.getNamespace()) || node.getPrefixFor(node.getNamespace()) != nodeTest.ns) {
                return false;
            }
        }

        // Check the tagname.
        if (nodeTest.tagname != '*' && node.getName() != nodeTest.tagname) {
            return false;
        }

        return true;
    }

    private Dom.XmlNode[] filterByPredicate(Dom.XmlNode[] nodes, Predicate predicate) {
        Dom.XmlNode[] retNodes  = new Dom.XmlNode[0];

        if (predicate.type == PRED_TYPE_NONE) {
            retNodes = nodes;
        }

        else if (predicate.type != PRED_TYPE_INDEX) {
            for (Dom.XmlNode newNode : nodes) {
                if (this.matchesSimplePredicate(newNode, predicate)) {
                    retNodes.add(newNode);
                }
            }
        }

        else {
            // If the predicate is an index-based filter (i.e. "[1]"), filter it here.
            if (0 < predicate.index
                    &&  predicate.index <= nodes.size()) {
                retNodes.add(nodes[predicate.index - 1]);
            }
        }

        return retNodes;
    }

    private Boolean matchesSimplePredicate(Dom.XmlNode node, Predicate predicate) {
        if (node.getNodeType() != Dom.XmlNodeType.ELEMENT) {
            return false;
        }

        // Now, filter it by the predicate if any.
        if (predicate.type == PRED_TYPE_INVALID) {
            // No further filtering on the results.
            return false;
        }

        if (predicate.type == PRED_TYPE_NONE) {
            // No further filtering on the results.
            return true;
        }

        if (predicate.type == PRED_TYPE_INDEX) {
            // Ignore this. Index predicate must be processed by the caller, since it's a higher-order
            // filter than can be determined by examining an individual node.
            return true;
        }

        if (predicate.type == PRED_TYPE_HAS_ATTR) {
            if (String.isEmpty(node.getAttribute(predicate.attrName, ''))) {
                return false;
            }
        }

        if (predicate.type == PRED_TYPE_ATTR_VALUE) {
            if (node.getAttribute(predicate.attrName, '') != predicate.attrValue) {
                return false;
            }
        }

        return true;
    }


    /*
     * Compiled form of a segment of a path like "/namespace:tagname", "namespace:*[1]", "tagname[@attr]" etc.
     * It's a structured representation that we can easily interpret & cache.
     */
    private class PathNode
    {
        Integer numSlashes = 1; // 0=start of a relative path, 1=children only, 2=all descendants
        public NodeTest nodeTest;
        public Predicate predicate;

        /*
         * Compiles a path node
         */
        public PathNode (String pathnode) {
            // Handle the path separator.
            if (pathnode.startsWith('//')) {
                this.numSlashes = 2;
                pathnode = pathnode.substringAfter('//');
            }
            else if (pathnode.startsWith('/')) {
                this.numSlashes = 1;
                pathnode = pathnode.substringAfter('/');
            }
            else {
                this.numSlashes = 0;
            }

            // Burst this node in the path into the tagname & predicate (if any).
            Pattern pPathnode = Pattern.compile(PD_XPath.rxNodeTest + PD_XPath.rxPredicate);
            Matcher mPathnode = pPathnode.matcher(pathnode);
            mPathnode.find();

            String nodeTestSrc = pathnode.substringBefore('[');
            this.nodeTest = new NodeTest(nodeTestSrc);

            String predicateSrc = pathnode.substringAfter(nodeTestSrc);
            this.predicate  = new Predicate(predicateSrc);
        }
    }


    /*
     * Compiled form of a node test like "namespace:tagname", "namespace:*", tagname", or "*".
     * It's a structured representation that we can easily interpret.
     */
    private class NodeTest
    {
        String ns = null;
        String tagname = null;

        /*
         * Compiles a node test.
         */
        public NodeTest (String src) {
            if (src.contains(':')) {
                this.ns = src.substringBefore(':');
                this.tagname = src.substringAfter(':');
            }
            else {
                this.tagname = src;
            }
        }


        public Boolean isDot () {
            return String.isEmpty(this.ns) && this.tagname == '.';
        }


        public Boolean isDoubleDot () {
            return String.isEmpty(this.ns) && this.tagname == '..';
        }
    }


    /*
     * Compiled form of a predicate expression like [1], [@attr], or [@attr=value].
     * It's a structured representation that we can easily interpret.
     */
    private class Predicate
    {
        public Integer type      = PRED_TYPE_NONE;
        public Integer index     = null;
        public String  attrName  = null;
        public String  attrValue = null;

        /*
         * Compiles a predicate expression.
         *
         * You can pass in a string with the [ ] or not.
         */
        public Predicate (String src) {
            if (String.isEmpty(src)) {
                this.type = PRED_TYPE_NONE;
                return;
            }

            src = src.substringAfter ('[');
            src = src.substringBeforeLast(']');
            if (src.isNumeric()) {
                this.type  = PRED_TYPE_INDEX;
                this.index = (Integer.valueOf(src));
            }

            else if (src.startsWith('@')) {
                src = src.substringAfter('@');
                if (src.contains('=')) {
                    this.type      = PRED_TYPE_ATTR_VALUE;
                    this.attrName  = src.substringBefore('=');
                    this.attrValue = src.substringAfter('=').removeStart('"').removeEnd('"');
                }
                else if (!String.isEmpty(src)) {
                    this.type      = PRED_TYPE_HAS_ATTR;
                    this.attrName  = src;
                }
                else  {// there is no predicate.
                    this.type      = PRED_TYPE_NONE;
                }
            }

            else {
                // ERROR!
                this.type = PRED_TYPE_INVALID;
            }
        }
    }
}