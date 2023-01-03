describe('Rotas Cardápio', () => {
    let id01;
    let id02;
    let id03;

    let idproduto01;
    let idproduto02;
    let idproduto03;
    let idproduto04;

    it('Create cardapio/produto', () => {
        cy.request({
            method: 'POST',
            url: '/cardapios',
            body: {
                "id": 0,
                "preco": 0.00,
                "descricao": "x-tudo",
                "produto": [
                    {
                        "id": 0,
                        "nome": "x-tudo",
                        "custo": 10.00,
                        "percentual_lucro": 50.00,
                        "estoque": 50,
                    }
                ],
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('cardapio adicionado com sucesso!');
            expect(Response.body[1].descricao).to.equal('x-tudo');
            expect(Response.body[1].preco).to.equal(15.00);
            expect(Response.body[1].produto[0].nome).to.equal('x-tudo');
            id01 = Response.body[1].id;
            idproduto01 = Response.body[1].produto[0].id;
        });
    });

    it('Create cardapio/combo', () => {
        cy.request({
            method: 'POST',
            url: '/cardapios',
            body: {
                "id": 0,
                "preco": 20.00,
                "descricao": "combo hot-dog",
                "produto": [
                    {
                        "id": 0,
                        "nome": "hot-dog",
                        "custo": 5.00,
                        "percentual_lucro": 50.00,
                        "estoque": 50,
                    },
                    {
                        "id": 0,
                        "nome": "coca-cola",
                        "custo": 7.00,
                        "percentual_lucro": 25.00,
                        "estoque": 20,
                    }
                ],
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('cardapio adicionado com sucesso!');
            expect(Response.body[1].descricao).to.equal('combo hot-dog');
            expect(Response.body[1].preco).to.equal(20.00);
            expect(Response.body[1].produto[0].nome).to.equal('hot-dog');
            expect(Response.body[1].produto[1].nome).to.equal('coca-cola');
            id02 = Response.body[1].id;
            idproduto02 = Response.body[1].produto[0].id;
            idproduto03 = Response.body[1].produto[1].id;
        });
    });

    it('Create cardapio/produto existente', () => {
        cy.request({
            method: 'POST',
            url: '/cardapios',
            body: {
                "id": 0,
                "preco": 30.00,
                "descricao": "combo x-tudo",
                "produto": [
                    {
                        "id": idproduto01,
                        "nome": "x-tudo",
                        "custo": 10.00,
                        "percentual_lucro": 50.00,
                        "estoque": 50,
                    },
                    {
                        "id": idproduto03,
                        "nome": "coca-cola",
                        "custo": 7.00,
                        "percentual_lucro": 25.00,
                        "estoque": 20,
                    }
                ],
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('cardapio adicionado com sucesso!');
            expect(Response.body[1].descricao).to.equal('combo x-tudo');
            expect(Response.body[1].preco).to.equal(30);
            expect(Response.body[1].produto[0].nome).to.equal('x-tudo');
            expect(Response.body[1].produto[1].nome).to.equal('coca-cola');
            id03 = Response.body[1].id;
        });
    });

    it('Get all cardapio', () => {
        cy.request('/cardapios').then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].id).to.equal(id01);
            expect(Response.body[0].descricao).to.equal('x-tudo');
            expect(Response.body[1].id).to.equal(id02);
            expect(Response.body[1].descricao).to.equal('combo hot-dog');
            expect(Response.body[2].id).to.equal(id03);
            expect(Response.body[2].descricao).to.equal('combo x-tudo');
        });
    });

    it('Get cardapio 01', () => {
        cy.request(`/cardapios/${id01}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id01);
            expect(Response.body.descricao).to.equal('x-tudo');
            expect(Response.body.preco).to.equal(15);
        });
    });

    it('Get cardapio 02', () => {
        cy.request(`/cardapios/${id02}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id02);
            expect(Response.body.descricao).to.equal('combo hot-dog');
            expect(Response.body.preco).to.equal(20.00);
        });
    });

    it('Get cardapio 03', () => {
        cy.request(`/cardapios/${id03}`).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.id).to.equal(id03);
            expect(Response.body.descricao).to.equal('combo x-tudo');
            expect(Response.body.preco).to.equal(20.00);
        });
    });

    it('Update cardapio 01', () => {
        cy.request({
            method: 'PUT',
            url: `/cardapios/${id01}`,
            body: {
                "id": 0,
                "preco": 18.00,
                "descricao": "x-tudo",
                "produto": [
                    {
                        "id": idproduto01,
                        "nome": "x-tudo",
                        "custo": 10.00,
                        "percentual_lucro": 50.00,
                        "estoque": 50,
                    }
                ],
            }
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body[0].message).to.equal('cardapio atualizado com sucesso!');
            expect(Response.body[1].descricao).to.equal('x-tudo');
            expect(Response.body[1].preco).to.equal(18.00);
            expect(Response.body[1].produto[0].nome).to.equal('x-tudo');
            expect(Response.body[1].id).to.equal(id01);
        });
    });

    it('Update cardapio 02', () => {
        cy.request({
            method: 'PUT',
            url: `/cardapios/${id02}`,
            body: {
                "id": 0,
                "preco": 20.00,
                "descricao": "combo hot-dog",
                "produto": [
                    {
                        "id": idproduto02,
                        "nome": "hot-dog",
                        "custo": 7.00,
                        "percentual_lucro": 50.00,
                        "estoque": 50,
                    },
                    {
                        "id": idproduto03,
                        "nome": "coca-cola",
                        "custo": 7.00,
                        "percentual_lucro": 30.00,
                        "estoque": 20,
                    }
                ],
            }
        }).then((Response) => {
            expect(Response.status).to.equal(201);
            expect(Response.body[0].message).to.equal('cardapio adicionado com sucesso!');
            expect(Response.body[1].descricao).to.equal('combo hot-dog');
            expect(Response.body[1].preco).to.equal(20.00);
            expect(Response.body[1].produto[0].nome).to.equal('hot-dog');
            expect(Response.body[1].produto[1].nome).to.equal('coca-cola');
            expect(Response.body[1].id).to.equal(id02);
        });
    });

    it('Delete cardapio 01', () => {
        cy.request({
            method: 'DELETE',
            url: `/cardapios/${id01}`
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.message).to.equal('cardapio excluído com sucesso!');
        });
    });

    it('Delete cardapio 02', () => {
        cy.request({
            method: 'DELETE',
            url: `/cardapios/${id02}`
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.message).to.equal('cardapio excluído com sucesso!');
        });
    });

    it('Delete cardapio 03', () => {
        cy.request({
            method: 'DELETE',
            url: `/cardapios/${id03}`
        }).then((Response) => {
            expect(Response.status).to.equal(200);
            expect(Response.body.message).to.equal('cardapio excluído com sucesso!');
        });
    });

    after(() => {
        cy.request({
            method: 'DELETE',
            url: `/produtos/${idproduto01}`,
            failOnStatusCode: false
        });
        cy.request({
            method: 'DELETE',
            url: `/produtos/${idproduto02}`,
            failOnStatusCode: false
        });
        cy.request({
            method: 'DELETE',
            url: `/produtos/${idproduto03}`,
            failOnStatusCode: false
        });
    });
});