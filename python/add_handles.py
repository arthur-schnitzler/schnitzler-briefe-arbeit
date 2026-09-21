import os
import glob
from tqdm import tqdm
from acdh_tei_pyutils.tei import TeiReader
from acdh_tei_pyutils.utils import get_xmlid
from acdh_handle_pyutils.client import HandleClient

files = sorted(glob.glob("./editions/*.xml"))

no_pids = []
for x in files:
    doc = TeiReader(x)
    xml_id = get_xmlid(doc.any_xpath("//tei:TEI")[0])
    url = f"https://id.acdh.oeaw.ac.at/schnitzler/schnitzler-briefe/editions/{xml_id}.xml"
    try:
        pid_node = doc.any_xpath(".//tei:idno[@type='handle']")[0]
    except IndexError:
        continue
    if pid_node.text is None:
        no_pids.append([x, url])
    elif "XXX" in pid_node.text:
        no_pids.append([x, url])
    else:
        continue
    

HANDLE_USERNAME = os.environ.get("username")
HANDLE_PASSWORD = os.environ.get("pw")

cl = HandleClient(HANDLE_USERNAME, HANDLE_PASSWORD)

for x in tqdm(no_pids, total=len(no_pids)):
    doc = TeiReader(x[0])
    pid_node = doc.any_xpath(".//tei:idno[@type='handle']")[0]
    result = cl.register_handle(x[1], full_url=True)
    pid_node.text = result
    doc.tree_to_file(x[0])




